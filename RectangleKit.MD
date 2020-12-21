
# RectangleKit


## RectangleKit Framework

### Input: 
##### List of zero or more rectangles, each rectangle has area greater than zero, each rectangle sits directly next to its neighbors on a common horizontal axis (i.e. there is no vertical gap between rectangles), and all rectangles sit flush on the common horizontal axis.

### Output: 
##### Shortest list of zero or more rectangle, each rectangle has area greater than zero, each rectangle sits directly on top of its neighbors (i.e. there is no horizontal gap between rectangles).  The output rectangles cover the same space as the input rectangles. By this we mean that the output rectangles have the same area as the input rectangles, and the silhouette / outline of the collection of output rectangles is the same as the silhouette / outline of the collection of input rectangle.

#### Function Defination 

```
//asynchronous call and run in background
public func rotatingRectangles(_ arrRects:[CGRect], _ completion:@escaping ([CGRect]) -> Void){
```

```
//synchronous call and run in same thread as caller 
public func rotatingRectangles(_ arrRects:[CGRect]) -> [CGRect] {
```

### Example: 

```
let arrInputRects = [CGRect.init(x: 0, y: 0, width: 20, height: 50),
                    CGRect.init(x: 20, y: 0, width: 30, height: 30),
                    CGRect.init(x: 50, y: 0, width: 20, height: 40)]
                    
let arrOutputRects = RectangleKit.shared.rotatingRectangles(arrInputRects)
                
RectangleKit.shared.rotatingRectangles(arrInputRects, {(arr) in
                self.arrOutputRects = arr
      print(arr)
})                
```

### Error Delegate

#### Error Delegate will call closure with error details in DEBUG MODE only 

#### Function Defination 

```
public func setDebugDelegate(_ completion: @escaping (Error) -> Void) {
```

### Example: 
```
RectangleKit.shared.setDebugDelegate({(error) in
            print(error)
        })
```        
        
