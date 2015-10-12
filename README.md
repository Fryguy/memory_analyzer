# MemoryAnalyzer

Ruby heap analyzer

## Installation

Clone the repo.

## Usage

```
bin/memory_analyzer /path/to/heap.json
```

This will parse the file and drop you into an IRB session

```
Parsing: |======================================================| Time: 00:00:03
[1] pry(main)>
```

From this point you have access to the heap in a variable called `$heap` upon
which you can call helper methods.

- `.file`: The file that was parsed
- `.nodes`: An `Array` of all memory objects
- `.index_by_address`: A `Hash` of all memory objects indexed by address
- `.index_by_location`: A `Hash` of all memory objects grouped by location,
  where location is `"#{file}:#{line}"`
- `.index_by_referencing_address`: A `Hash` of all memory objects grouped by
  the address of the object that is referencing them (i.e. their "parents").
- `.roots`: A `Set` of all root objects
- `.find_by_location(regex)`: Finds the first object whose location matches the
  provided `regex`
- `.walk_references(address)`: Walks the object graph, printing objects in a
  tree structure, starting from the given `address`
- `.walk_parents(address)`: Walks the object graph, in reverse, printing objects
  in a tree structure, starting from the given `address`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fryguy/memory_analyzer.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

