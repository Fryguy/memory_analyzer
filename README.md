# Memory Analyzer

Ruby heap analyzer

## Usage

```
cd lib
ruby heap_analyzer.rb /path/to/heap.json
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
