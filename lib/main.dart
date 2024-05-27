import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sqliteflutter/addnewquote.dart';
import 'package:sqliteflutter/favouritepage.dart';
import 'package:sqliteflutter/theme.dart';
import 'dbhelper.dart';
import 'QuotesDataModel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Quotes> quotes_list = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return runApp(ChangeNotifierProvider(
      child: const MyApp(),
      create: (BuildContext context) =>
          ThemeProvider(isDarkMode: prefs.getBool("isDarkTheme") ?? false)));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Dbhelper handler;
  RewardedAd? rewardedAd;
  bool isLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initRewardedAd();
    getData();
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

  void getData() async {
    var dbhelper = Dbhelper();
    List<Quotes> quotesList = await dbhelper.getQuotes();
    setState(() {
      quotesList = quotesList;
    });
  }

  void update(int fav, int index) async {
    var dbhelper = Dbhelper();
    dbhelper.updateFav(fav, quotes_list[index].id);
    // print(fav);
    // print(index);
  }

  void lockUpdate(int lock, int index) async {
    var dbhelper = Dbhelper();
    print("Lock: $lock, idx: $index");
    dbhelper.updateLock(lock, quotes_list[index].id);
    // print(fav);
    // print(index);
  }

  void deleteData(int index) async {
    var dbhelper = Dbhelper();
    dbhelper.deleteQuote(quotes_list[index].id);
  }

  Widget FavouriteQuote(int index) {
    return (quotes_list[index].favourites == 1)
        ? IconButton(
            icon: const Icon(
              Icons.star,
              size: 25,
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
              size: 25,
            ),
            color: Colors.amber,
            onPressed: () {
              setState(() {
                update(1, index);
              });
            },
          );
  }

  Widget DeleteQuote(int index) {
    return IconButton(
      icon: const Icon(
        Icons.delete_outline,
        size: 25,
      ),
      color: Colors.redAccent,
      onPressed: () {
        deleteData(index);
      },
    );
  }

  Widget WholeContent(BuildContext buildContext) {
    return Builder(builder: (buildContext) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Quotes"),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(buildContext).pushNamed('/addNewQuote');
                },
              ),
              IconButton(
                icon: const Icon(Icons.star),
                color: Colors.amber,
                onPressed: () {
                  Navigator.of(buildContext).pushNamed('/favouriteQuote');
                },
              ),
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () {
                  ThemeProvider themeProvider =
                      Provider.of<ThemeProvider>(context, listen: false);
                  themeProvider.swapTheme();
                },
              ),
            ],
          ),
          body: Container(
              child: ListView.separated(
            separatorBuilder: (context, index) =>
                const Divider(height: 0.5, color: Colors.black38),
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            // ignore: unnecessary_null_comparison
            itemCount: quotes_list == null ? 0 : quotes_list.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        title: Text(
                          quotes_list[index].quotes,
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        trailing: Wrap(
                          spacing: 1,
                          children: [
                            if (quotes_list[index].lock == 1)
                              IconButton(
                                  onPressed: () {
                                    if (isLoaded) {
                                      if (rewardedAd != null) {
                                        rewardedAd!.fullScreenContentCallback =
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
                                          onUserEarnedReward: (ad, rewardItem) {
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
                            DeleteQuote(index),
                          ],
                        ))),
              );
            },
          )));
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.getTheme,
          routes: <String, WidgetBuilder>{
            '/addNewQuote': (BuildContext context) => const AddNewQuote(),
            '/favouriteQuote': (BuildContext context) => const FavouritePage()
          },
          home: WholeContent(buildContext),
        );
      },
    );
  }
}
