//
//  TagedBooksViewController.swift
//  Bukuma_ios_swift
//
//  Created by khara on 7/10/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

// 無駄は多々あるが、表示的にほぼ等しい MerchandiseHomeCollectionViewController を踏襲する
class TagedBooksViewController: HomeCollectionViewController {
    override open func registerDataSourceClass() -> AnyClass? {
        return TagedBooksDataSource.self
    }

    override open func initializeNavigationLayout() {
        self.title = (self.dataSource as? TagedBooksDataSource)?.tag?.displayName
    }

    override open func pullToRefreshInsetTop() -> CGFloat {
        return  NavigationHeightCalculator.navigationHeight()
    }

    override func collectionScrollBottom() ->CGFloat {
        return 0
    }

    required init (withTag tag: Tag) {
        super.init(nibName: nil, bundle: nil)

        (self.dataSource as? TagedBooksDataSource)?.tag = tag
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.contentInset.bottom = 0
        self.viewReloadOnlyDataUpdated = true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.reloadCollectionView()
    }

    override func registerStatusBarNotification() {}
}
