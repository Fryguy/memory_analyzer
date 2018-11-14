require 'singleton'
require 'pathname'
require 'tmpdir'
require 'time'

class RubyGCLogger
  include Singleton

  def start_gc_statistics_thread(seconds = 60)
    require 'objspace'

    begin
      require 'sys-proctable'
    rescue LoadError
      puts "sys-proctable isn't installed, run gem install sys-proctable"
      exit 1
    end

    file_name                 = Pathname.new(Dir.tmpdir).join("#{Process.pid}.csv")
    csv                       = File.open(file_name, "w+")
    csv.sync                  = true
    Thread.abort_on_exception = true

    puts "Writing to #{file_name}"
    @gc_stat_thread = Thread.new do
      csv.puts(gc_stat_header.join(",".freeze))
      loop do
        csv.puts(gc_stat_line.join(",".freeze))
        sleep seconds
      end
    end

    at_exit { csv.close }
    csv.path
  end

  def self.gc_stat_now
    instance.gc_stat_now
  end

  def gc_stat_now
    @gc_stat_thread.wakeup
    Thread.pass
  end

  private

  def gc_stat_line
    gc_stat       = GC.stat
    live_objects  = gc_stat[:total_allocated_objects] - gc_stat[:total_freed_objects]
    young_objects = live_objects - gc_stat[:old_objects]

    ps = Sys::ProcTable.ps(Process.pid)
    [Time.now.iso8601, live_objects, young_objects, ObjectSpace.memsize_of_all] +
      memory_keys.collect {|k| ps.send(k)} +
      gc_stat.values_at(*gc_stat_keys) +
      ObjectSpace.count_objects.values_at(*count_objects_keys) +
      ObjectSpace.count_objects_size.values_at(*count_objects_size_keys)
  end

  def gc_stat_header
    [:time, :live_objects, :young_objects, :memsize_of_all] +
      memory_keys +
      gc_stat_keys +
      count_objects_keys +
      count_objects_size_keys.collect { |key| key.to_s.concat("_SIZE").to_sym }
  end

  def gc_stat_keys
    @gc_stat_keys ||= GC.stat.keys
  end

  def memory_keys
    @memory_keys ||= [:rss, :vsize]
  end

  def count_objects_keys
    @count_objects_keys ||= ObjectSpace.count_objects.keys
  end

  def count_objects_size_keys
    @count_objects_size_keys ||= ObjectSpace.count_objects_size.keys
  end
end
