
# RectangleKit


## RectangleKit Framework

### Input: 
##### List of zero or more rectangles, each rectangle has area greater than zero, each rectangle sits directly next to its neighbors on a common horizontal axis (i.e. there is no vertical gap between rectangles), and all rectangles sit flush on the common horizontal axis.

### Output: 
##### Shortest list of zero or more rectangle, each rectangle has area greater than zero, each rectangle sits directly on top of its neighbors (i.e. there is no horizontal gap between rectangles).  The output rectangles cover the same space as the input rectangles. By this we mean that the output rectangles have the same area as the input rectangles, and the silhouette / outline of the collection of output rectangles is the same as the silhouette / outline of the collection of input rectangle.

### RectangleKit written in Swift.

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
        




# RectangleKitDemo Application 

##### Test application that uses RectangleKit. The application creates the input list (generated randomly), sends this list to RectangleKit to do the calculations, and then shows the output list of rectangle. The application should graphically display the input and output lists. The test application written in Swift, and use SwiftUI to display the list of rectangles graphically.


#### Two Navigation bar buttons for Dummy Data:
 
#### 1. "Random Input" button :  
##### => creates the input list of CGRect (generated randomly). Method name "HomeViewModel"->"randomRectsInput" 
##### => Method name "HomeViewModel"->"randomRectsInput" 
##### => Random Number of Rantangle 1..<15
##### => Random width 10..<50
##### => Random height 10..<150

#### 2. "Select Input" button :  
##### => Read the input list from the local dummy "mock.josn" file  
##### => Method name "HomeViewModel"->"fetchDummyData" 
##### => In Dummy Input from "mock.json" last Input is Invalid input to test Error Handler and will return empty output array.

  

# RectangleKit Code Files

```
# RectangleKit.swift:  Main file with public methods and Algorithm logic. 
    - Time Complecity O(n) - where n = Number of Rectangle in Input array
    - Space complecity O(n) in worst case, best case : O(1)
# RectangleKitStack.swift: Created custom stack for keep height and index of the rectangle. used stack instead of Array for Push and Pop in O(1) time.    
# RectangleKitErrorType.swift : Defined different Error types. 

```

# RectangleKitDemo Code Files

```
# ContentView.swift:Main View File 
# HomeViewModel.swift: View Model class for Main View
# Rentangle.swift: Model file for Main View Dummy Data.
# "Utilities" Group for Defined different Error types. 
# "Network" Group for Network call, for now used for read mock.json dummy data file. but we can easly change to server URL if needed in future. 
```
