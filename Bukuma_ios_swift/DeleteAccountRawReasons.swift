//
//  DeleteAccountRawReasons.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/20/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

//  "delete_account_items: [
//      {
//          "item_title": "表示文字列",
//          "item_value": アイテムを表す数値,
//          以下があるか無いか
//          "child_items": [
//              {
//                  "item_title": "表示文字列",
//                  "item_value": アイテムを表す数値
//              },
//              {
//                  "item_title": "表示文字列",
//                  "item_value": アイテムを表す数値
//              },
//              {
//                  "item_title": "表示文字列",
//                  "item_value": アイテムを表す数値
//              }
//          ]
//      },
//      {
//          "item_title": "表示文字列",
//          "item_value": アイテムを表す数値,
//          以下があるか無いか
//          "child_items": [
//              {
//                  "item_title": "表示文字列",
//                  "item_value": アイテムを表す数値
//              },
//              {
//                  "item_title": "表示文字列",
//                  "item_value": アイテムを表す数値
//              },
//              {
//                  "item_title": "表示文字列",
//                  "item_value": アイテムを表す数値
//              }
//          ]
//      }
//  ]

class DeleteAccountRawReasons {
    private static let rawReasons: [String: Any?] = [
        "delete_account_reasons": [[
            "item_title": "出品が少ない",
            "item_value": 0,
            "child_items": [[
                "item_title": "目当ての本がなかった",
                "item_value": 10], [
                "item_title": "良いと思える商品が少ない",
                "item_value": 11], [
                "item_title": "好きなカテゴリの本が少ない",
                "item_value": 12], [
                "item_title": "出品されている書籍の価格が高い",
                "item_value": 13], [
                "item_title": "その他",
                "item_value": 14]]], [
            "item_title": "出品した本が売れない",
            "item_value": 20], [
            "item_title": "取引に不安がある",
            "item_value": 0,
            "child_items": [[
                "item_title": "ユーザー同士でのトラブルがあった",
                "item_value": 30], [
                "item_title": "見知らぬ人とのやり取りが怖い",
                "item_value": 31], [
                "item_title": "普通・悪い評価をつけられた",
                "item_value": 32], [
                "item_title": "その他",
                "item_value": 33]]], [
            "item_title": "使い方がわからない",
            "item_value": 0,
            "child_items": [[
                "item_title": "出品方法について",
                "item_value": 40], [
                "item_title": "購入方法について",
                "item_value": 41], [
                "item_title": "配送について",
                "item_value": 42], [
                "item_title": "価格設定について",
                "item_value": 43], [
                "item_title": "梱包について",
                "item_value": 44], [
                "item_title": "その他",
                "item_value": 45]]], [
            "item_title": "アプリが使いにくい",
            "item_value": 0,
            "child_items": [[
                "item_title": "決済の選択肢が少ない",
                "item_value": 50], [
                "item_title": "匿名配送がないので不安",
                "item_value": 51], [
                "item_title": "探している本が出てこない",
                "item_value": 52], [
                "item_title": "不具合が多い",
                "item_value": 53], [
                "item_title": "その他",
                "item_value": 54]]], [
            "item_title": "もう使わなくなったから",
            "item_value": 0,
            "child_items": [[
                "item_title": "全て売り切った・売るものがなくなったから",
                "item_value": 60], [
                "item_title": "忙しくて使う時間がないから",
                "item_value": 61], [
                "item_title": "アプリの容量が少ないから",
                "item_value": 62], [
                "item_title": "海外へ行くから",
                "item_value": 63], [
                "item_title": "その他",
                "item_value": 64]]], [
            "item_title": "運営側に不満がある",
            "item_value": 0,
            "child_items": [[
                "item_title": "お知らせが多い",
                "item_value": 70], [
                "item_title": "運営とのやり取りに不満がある",
                "item_value": 71], [
                "item_title": "その他",
                "item_value": 72]]], [
            "item_title": "他サービスを利用するから",
            "item_value": 0,
            "child_items": [[
                "item_title": "メルカリ",
                "item_value": 80], [
                "item_title": "メルカリ カウル",
                "item_value": 81], [
                "item_title": "フリル",
                "item_value": 82], [
                "item_title": "ラクマ",
                "item_value": 83], [
                "item_title": "モノキュン！",
                "item_value": 84], [
                "item_title": "オタマート",
                "item_value": 85], [
                "item_title": "その他",
                "item_value": 86]]], [
            "item_title": "その他",
            "item_value": 0,
            "child_items": [[
                "item_title": "機能を制限されたから",
                "item_value": 90], [
                "item_title": "飽きたから",
                "item_value": 91], [
                "item_title": "その他",
                "item_value": 92]]]
        ]]

    static func get(withCompletion completion: (_ rawReasons: [[String: Any?]]?, _ error: Error?) -> Void) {
        let rawReasons = self.rawReasons["delete_account_reasons"] as! [[String: Any?]]
        completion(rawReasons, nil)
    }
}
