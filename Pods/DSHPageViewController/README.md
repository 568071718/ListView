
轻量级分页控制器

```
pod 'DSHPageViewController', :git => 'https://github.com/568071718/PageViewController.git'
```

```
ViewController *vc1 = ... ;
ViewController *vc2 = ... ;
ViewController *vc3 = ... ;

NSArray *viewControllers = @[vc1 ,vc2 ,vc3];
DSHPageViewController *pageViewController = [[DSHPageViewController alloc] initWithViewControllers:viewControllers];
pageViewController.view.frame = ... ;
[self.view addSubview:pageViewController.view];
[self addChildViewController:pageViewController];
```
