//
//  CordingRule.swift
//  Bukuma_ios_swift
//
//  Created by Hiroshi Chiba on 2016/03/29.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//




/*
 
 ①　このアプリはModel-View-ViewControllerで設計されています.
   　データを扱うObjectやサーバーとの通信はModel, 見た目はView,Viewが捜査された時の挙動など、ユーザーの操作を扱うのがViewControllerです
      ex. HomeCollectionViewでいうと
        Model: Book,HomeDataSource
        View:collectionView,HomeCollectionCell,HomeTabLabel
        ViewController: HomeCollectionViewController(このアプリの場合NKJPagerViewControllerというライブラリを使っているので、HomeViewControllerがHomeCollectionViewControllerを表示させているコードになっていますが)
 
 ②　継承関係について
    BaseClassのクラスから継承されています。
 
 ③　
 
 
 
 
 
 
 
 */
