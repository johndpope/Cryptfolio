//
//  CryptoData.swift
//  TestGetCryptoData
//
//  Created by Andre Staffa on 2020-04-16.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import Alamofire;

public struct Ticker : Codable {
    let id:Int;
    let name:String;
    let symbol:String;
    let rank:Int;
    var price:Double;
    let changePrecent24H:Double;
    let volume24H:Double;
    let marketCap:Double;
    let circulation:Double;
    var description:String
    let website:String;
    let allTimeHigh:Double
    let history24h:[Double]
}

public struct News : Codable {
    let title:String;
    let source:String;
    let publishedOn:Double;
    let url:String;
}

public struct History : Codable {
    let prices:[Double]
    let timestamps:[Double];
}

public struct PortfolioData : Codable {
    let currentPrice:Double;
    let currentDate:String;
}

public class CryptoData {
    
//    public static func getCryptoData(completion:@escaping (Ticker?, Error?) -> Void) {
//        let symbols = readTextToArray(path: "Data.bundle/cryptoTickers");
//        let names = readTextToArray(path: "Data.bundle/cryptoNames");
//        let descriptions = readTextToArray(path: "Data.bundle/cryptoDescriptionsNew");
//        let websites = readTextToArray(path: "Data.bundle/cryptoWebsites");
//        let reddit = readTextToArray(path: "Data.bundle/cryptoReddit");
//        var longString:String = "";
//        for symbol in symbols! {
//            longString += symbol + ",";
//        }
//        longString.removeLast();
//        let url:URL = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=" + longString + "&tsyms=USD")!
//         AF.request(url).responseJSON { response in
//             if let json = response.value {
//                for index in 0...symbols!.count - 1 {
//                    let jsonObject:Dictionary = json as! Dictionary<String, Any>;
//                    let dataObject:Dictionary = jsonObject["RAW"] as! Dictionary<String, Any>;
//                    let coin:Dictionary = dataObject[symbols![index]] as! Dictionary<String, Any>;
//                    let USD_lbl:Dictionary = coin["USD"] as! Dictionary<String, Any>;
//                    let price:Double = (USD_lbl["PRICE"] as? Double)!;
//                    let changePercent24H:Double = (USD_lbl["CHANGEPCT24HOUR"] as? Double)!;
//                    let volume24H:Double = (USD_lbl["VOLUME24HOUR"] as? Double)!;
//                    let marketCap:Double = (USD_lbl["MKTCAP"] as? Double)!;
//                    let circulation:Double = (USD_lbl["SUPPLY"] as? Double)!;
//                    let ticker = Ticker(name: names![index], symbol: symbols![index], rank: index+1, price: price, changePrecent24H: changePercent24H, volume24H: volume24H, marketCap: marketCap, circulation: circulation, description: descriptions![index], website: websites![index], redditLink: reddit![index]);
//                    completion(ticker, nil);
//                }
//
//             } else if let error = response.error {
//                 completion(nil, error);
//             }
//         }
//     }
    
    public static func getCoinHistory(id: Int, timeFrame:String, completion:@escaping (History?, Error?) -> Void) -> Void {
        let url = URL(string: "https://api.coinranking.com/v1/public/coin/" + "\(id)" + "/history/" + "\(timeFrame)");
        if (url == nil) {
            print("error loading history, url was nil");
            return;
        }
        AF.request(url!).responseJSON { (response) in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let historys = data["history"] as! [[String: Any]];
                var prices = [Double]();
                var timestamps = [Double]();
                for i in 0...historys.count - 1 {
                    let price = historys[i]["price"] as? String;
                    let timestamp = historys[i]["timestamp"] as? Double;
                    let priceDouble = Double(price ?? "0.0");
                    let timestampDouble = Double(timestamp ?? 0);
                    prices.append(priceDouble!);
                    timestamps.append(timestampDouble);
                }
                completion(History(prices: prices, timestamps: timestamps), nil);
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getNewsData(completion:@escaping (News?, Error?) -> Void) -> Void {
        let url = URL(string: "https://min-api.cryptocompare.com/data/v2/news/?lang=EN");
        if (url == nil) {
            print("url was nil");
            return;
        }
        AF.request(url!).responseJSON { (response) in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data = jsonObject["Data"] as! [Dictionary<String, Any>];
                for index in 0...data.count - 1 {
                    let title = data[index]["title"] as! String;
                    let sourceInfo:Dictionary = data[index]["source_info"] as! Dictionary<String, Any>;
                    let source = sourceInfo["name"] as! String;
                    let publishedOn = data[index]["published_on"] as! Double;
                    let urlString = data[index]["url"] as! String;
                    let news = News(title: title, source: source, publishedOn: publishedOn, url: urlString);
                    completion(news, nil);
                }
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getCoinData(id: Int, completion:@escaping (Ticker?, Error?) -> Void) -> Void {
        let url = URL(string: "https://api.coinranking.com/v1/public/coin/" + "\(id)");
        if (url == nil) {
            return;
        }
        AF.request(url!).responseJSON { (response) in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let coin:Dictionary = data["coin"] as! Dictionary<String, Any>;
                // get properties
                let id = coin["id"] as! Int;
                let name = coin["name"] as? String;
                let symbol = coin["symbol"] as? String;
                let rank = coin["rank"] as? Int;
                let priceString = coin["price"] as? String;
                let price  = Double(priceString ?? "0.0");
                let change =  coin["change"] as? Double;
                let volume = coin["volume"] as? Double;
                let marketCap = coin["marketCap"] as? Double;
                let circulation = coin["circulatingSupply"] as? Double;
                let description = coin["description"] as? String;
                let website = coin["websiteUrl"] as? String;
                let allTimeHigh = coin["allTimeHigh"] as! Dictionary<String, Any>;
                let allTimeHighPriceString = allTimeHigh["price"] as? String
                let allTimeHighPriceDouble = Double(allTimeHighPriceString ?? "0.0");
                let history24hString = coin["history"] as? [String];
                var historyDouble = [Double]();
                if (history24hString != nil) {
                    historyDouble = history24hString!.map { Double($0) } as! [Double]
                } else {
                    historyDouble = [Double]();
                }
                let ticker = Ticker(id: id, name: name ?? "No Name", symbol: symbol ?? "No symbol", rank: rank ?? 0, price: price!, changePrecent24H: change ?? 0.0, volume24H: volume ?? 0.0, marketCap: marketCap ?? 0.0, circulation: circulation ?? 0.0, description: description ?? "No Description Available", website: website ?? "No Website Available", allTimeHigh: allTimeHighPriceDouble!, history24h: historyDouble)
                completion(ticker, nil);
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getCryptoData(completion:@escaping (Ticker?, Error?) -> Void) -> Void {
        let url = URL(string: "https://api.coinranking.com/v1/public/coins?limit=100");
        if (url == nil) {
            return;
        }
        AF.request(url!).responseJSON { response in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let coins = data["coins"] as! [[String: Any]];
                for i in 0...coins.count - 1 {
                    let id = coins[i]["id"] as! Int;
                    let name = coins[i]["name"] as? String;
                    let symbol = coins[i]["symbol"] as? String;
                    let rank = coins[i]["rank"] as? Int;
                    let priceString = coins[i]["price"] as? String;
                    let price  = Double(priceString ?? "0.0");
                    let change =  coins[i]["change"] as? Double;
                    let volume = coins[i]["volume"] as? Double;
                    let marketCap = coins[i]["marketCap"] as? Double;
                    let circulation = coins[i]["circulatingSupply"] as? Double;
                    let description = coins[i]["description"] as? String;
                    let website = coins[i]["websiteUrl"] as? String;
                    let allTimeHigh = coins[i]["allTimeHigh"] as! Dictionary<String, Any>;
                    let allTimeHighPriceString = allTimeHigh["price"] as? String
                    let allTimeHighPriceDouble = Double(allTimeHighPriceString ?? "0.0");
                    let history24hString = coins[i]["history"] as? [String];
                    var historyDouble = [Double]();
                    if (history24hString != nil) {
                        historyDouble = history24hString!.map { Double($0) } as! [Double]
                    } else {
                        historyDouble = [Double]();
                    }
                    let ticker = Ticker(id: id, name: name ?? "No Name", symbol: symbol ?? "No symbol", rank: rank ?? 0, price: price!, changePrecent24H: change ?? 0.0, volume24H: volume ?? 0.0, marketCap: marketCap ?? 0.0, circulation: circulation ?? 0.0, description: description ?? "No Description Available", website: website ?? "No Website Available", allTimeHigh: allTimeHighPriceDouble!, history24h: historyDouble)
                    completion(ticker, nil);
                }
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func readTextToArray(path:String) -> Array<String>? {
        var arrayOfStrings: Array<String>?
        do {
            // This solution assumes  you've got the file in your bundle
            if let path = Bundle.main.path(forResource: path, ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8);
                arrayOfStrings = data.components(separatedBy: "\n");
                arrayOfStrings!.remove(at: arrayOfStrings!.count - 1);
//                for index in 0...arrayOfStrings!.count - 1 {
//                    arrayOfStrings![index].removeLast();
//                }
                return arrayOfStrings;
            }
        } catch let err as NSError {
            arrayOfStrings = [String()];
            print(err);
            return arrayOfStrings;
        }
        arrayOfStrings = [String()];
        return arrayOfStrings;
    }
    
}
