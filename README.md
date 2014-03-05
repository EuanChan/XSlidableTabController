XSlidableTabController
=========================

slidable tab view controller, may use to create news column. 

![Demo](https://raw.github.com/EuanChan/XSlidableTabController/master/Screenshot/screenshot1.gif)

###Guide
make a new class inherited from XSliableTabControll, initialize columns in viewDidLoad

``` objc

    - (void)viewDidLoad 
    {
	    [super viewDidLoad];
	    self.title = @"News";
			
	    UIViewController *vc1 = [[UIViewControll alloc] initWithTitle:@"Column1"];
	    UIViewController *vc2 = [[UIViewControll alloc] initWithTitle:@"Column2"];
	    UIViewController *vc3 = [[UIViewControll alloc] initWithTitle:@"Column3"];
	    UIViewController *vc4 = [[UIViewControll alloc] initWithTitle:@"Column4"];
	    UIViewController *vc5 = [[UIViewControll alloc] initWithTitle:@"Column5"];
		
	    NSArray *columns = @[vc1, vc2, vc3, vc4, vc5];
	    [super setViewControllers:columns];
    }
	
```

you should update data by implement the XSlidableTabControllerDelegate if need,

``` objc

    - (void)didSwitchToTabAtIndex:(NSInteger)index
    {
    	// it's turn to viewcontroll at index to do update data.
    }

```
