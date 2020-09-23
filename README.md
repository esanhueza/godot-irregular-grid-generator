# Grid Generator
A simple grid generator to enable the generation of a hexagonal grid that contains tiles with a irregular shape.


## Usage
```python
var generator = IrregularHexGridGenerator.new()
generator.rings = 5
generator.radius = 5
generator.relax_iterations = 30

var quads = generator.generate()
```

## Examples
![Result](/examples/images/grid_example.png)
![Terrain generated using grid](/examples/images/terrain_example.png)
