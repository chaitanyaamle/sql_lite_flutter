import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'QuotesDataModel.dart';
import 'dbhelper.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  RewardedAd? rewardedAd;
  bool isLoaded = false;

List<Quotes> quotes_list = [];


  void lockUpdate(int lock, int index) async {
    var dbhelper = Dbhelper();
    print("Lock: $lock, idx: $index");
    dbhelper.updateLock(lock, quotes_list[index].id);
    quotes_list[index].lock = lock;
    setState(() { });
    // print(fav);
    // print(index);
  }

  void update(int fav, int index) async {
    var dbhelper = Dbhelper();
    quotes_list[index].favourites = fav;
    dbhelper.updateFav(fav, quotes_list[index].id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    initRewardedAd();
  }

  void initRewardedAd() {
    RewardedAd.load(
        adUnitId: "ca-app-pub-3940256099942544/5224354917",
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
          rewardedAd = ad;
          isLoaded = true;
        }, onAdFailedToLoad: (err) {
          print("Rewarded Error: $err");
        }));
  }

  Widget FavouriteQuote(int index) {
    return (quotes_list[index].favourites == 1)
        ? IconButton(
            icon: const Icon(
              Icons.star,
              size: 30,
            ),
            color: Colors.amber,
            onPressed: () {
              setState(() {
                update(0, index);
              });
            })
        : IconButton(
            icon: const Icon(
              Icons.star_border,
              size: 30,
            ),
            color: Colors.amber,
            onPressed: () {
              setState(() {
                update(1, index);
              });
            },
          );
  }

  Widget ShowNoQuoteMessage() {
    return Column(
      children: [
        Container(
            margin: const EdgeInsets.fromLTRB(20, 180, 20, 0),
            child: const Text("No Favourite Quotes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        AlertDialog(
          title: const Text("No Favourite Quotes"),
          content: const SingleChildScrollView(
            child: Text("No favourite quotes added in the list."),
          ),
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Favourite Quotes"),
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back),
              ),
            ),
            body: Container(
                child: (quotes_list.isEmpty)
                    ? ShowNoQuoteMessage()
                    : ListView.separated(
                        separatorBuilder: (context, index) =>
                            const Divider(height: 0.5, color: Colors.black38),
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: quotes_list.isEmpty ? 0 : quotes_list.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    quotes_list[index].quotes,
                                    style: const TextStyle(fontSize: 15.0),
                                  ),
                                  trailing: Wrap(
                                    children: [
                                      if (quotes_list[index].lock == 1)
                                        IconButton(
                                            onPressed: () {
                                              if (isLoaded) {
                                                if (rewardedAd != null) {
                                                  rewardedAd!
                                                          .fullScreenContentCallback =
                                                      FullScreenContentCallback(
                                                          onAdDismissedFullScreenContent:
                                                              (ad) {
                                                    ad.dispose();
                                                    initRewardedAd();
                                                  }, onAdFailedToShowFullScreenContent:
                                                              (ad, err) {
                                                    ad.dispose();
                                                    initRewardedAd();
                                                  });
                                                }
                                                rewardedAd!.show(
                                                    onUserEarnedReward:
                                                        (ad, rewardItem) {
                                                  setState(() {
                                                    lockUpdate(0, index);
                                                  });
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.lock,
                                            ))
                                      else
                                        const SizedBox(
                                          width: 0,
                                        ),
                                      FavouriteQuote(index),
                                    ],
                                  ),
                                )),
                          );
                        }))));
  }

  void getData() async {
    var dbhelper = Dbhelper();
    List<Quotes> quotesList = await dbhelper.getFavQuotes();
    print("QUOTE: $quotesList");
    setState(() {
      quotes_list = quotesList;
    });
  }
}

// return (quotes_list[index].favourites == 1)
// ? const Icon(
// Icons.star,
// size: 30,
// color: Colors.amber,
// )
// : const Icon(
// Icons.star_border,
// size: 30,
// color: Colors.amber,
// );
