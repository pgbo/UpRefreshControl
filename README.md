# UpRefreshControl

## 简介

使用Objective-c编写的下拉刷新控件，适用于各种UIScrollView，UITableView，UICollectionView，其特点是简洁大方。

## 效果图
下拉状态：  
![下拉可以刷新...](/Snapshoot/snapshoot_0.jpg)

准备刷新状态：    
![释放将会刷新...](/Snapshoot/snapshoot_1.jpg)

刷新中状态：    
![刷新中...](/Snapshoot/snapshoot_2.jpg)

## 安装
### cocoapods
将下面的语句加入到你的Podfile：
```ruby
pod "UpRefreshControl", :git => "https://github.com/pgbo/UpRefreshControl.git"
```

### 手动安装
拷贝并添加或推拽UpRefreshControl目录到你的项目目录里即可。

## 使用
### 初始化并添加到UIScrollView中
```` objective-c
_refreshControl = [[UpRefreshControl alloc]initWithScrollView:self.tableView action:^(UpRefreshControl *control){
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[control finishedLoadingWithStatus:@"Finished refresh" delay:1.f];
});
}];
[self.tableView addSubview:self.refreshControl];
````

### 结束刷新
```` objective-c
[self.refreshControl finishedLoadingWithStatus:@"Finished refresh" delay:1.f];
````

### 在UIScrollView相关代理方法中调用UpRefreshControl的相关方法
```` objective-c
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
[self.refreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
[self.refreshControl scrollViewDidEndDragging];
}
````

### 自定义
```` objective-c
// 自定义颜色
self.refreshControl.color = [UIColor blueColor];

// 自定义触发加载更多的阀值
self.refreshControl.refreshThreshold = 100.f;
````

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

pgbo, 460667915@qq.com

## License

UpRefreshControl is available under the MIT license. See the LICENSE file for more info.
