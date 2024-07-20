import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gatherly/core/constants/style.dart';
import 'package:gatherly/core/widgets/stall_card.dart';
import 'package:gatherly/core/widgets/custom_searchbar.dart';
import 'package:gatherly/core/widgets/base_text.dart';
import 'package:gatherly/data/models/data_stall.dart';
import 'package:gatherly/data/models/stall_detail.dart';
import 'package:gatherly/presentation/bloc/home_bloc.dart';
import 'package:gatherly/presentation/bloc/stall_page_bloc.dart';
import 'package:gatherly/presentation/screens/stall_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HomeBloc homeBloc = HomeBloc();
  late List<StallBloc> stallBlocList;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    homeBloc.stallsStream.listen((stalls) {
      setState(() {
        stallBlocList = List.generate(
            stalls.length,
            (index) => StallBloc('mediaBox_$index',
                useFirestore: homeBloc.useFirestore));
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      homeBloc.setShowSearchBar(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      homeBloc.setShowSearchBar(true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    homeBloc.dispose();
    for (var manager in stallBlocList) {
      manager.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshData() async {
    homeBloc.fetchData();
  }

  void _showLoaderDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  void _hideLoaderDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _toggleFirestore() async {
    final message = homeBloc.useFirestore
        ? "Connecting to offline"
        : "Connecting to online";
    _showLoaderDialog(message);

    homeBloc.switchToFirestore(!homeBloc.useFirestore);
    await Future.delayed(const Duration(seconds: 12));
    _hideLoaderDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<StallDetail>>(
        stream: homeBloc.stallsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final stalls = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                StreamBuilder<bool>(
                  stream: homeBloc.showSearchBarStream,
                  builder: (context, showSearchBarSnapshot) {
                    final showSearchBar = showSearchBarSnapshot.data ?? true;
                    return SliverAppBar(
                      floating: true,
                      pinned: true,
                      snap: false,
                      expandedHeight: 120.0,
                      flexibleSpace: const FlexibleSpaceBar(
                        titlePadding: EdgeInsets.only(left: 24),
                        title: BaseText(
                          text: 'Stalls',
                          style: CustomTextStyles.headline1,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      actions: showSearchBar
                          ? [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: CustomSearchBar(
                                    controller: _searchController,
                                    hintText: 'Search',
                                    onChanged: (value) {},
                                    onSubmitted: (value) {},
                                  ),
                                ),
                              ),
                              StreamBuilder<bool>(
                                stream: homeBloc.firestoreStream,
                                builder: (context, snapshot) {
                                  final useFirestore = snapshot.data ?? false;
                                  return IconButton(
                                    icon: Icon(useFirestore
                                        ? Icons.cloud
                                        : Icons.cloud_off),
                                    onPressed: _toggleFirestore,
                                  );
                                },
                              ),
                            ]
                          : [
                              StreamBuilder<bool>(
                                stream: homeBloc.firestoreStream,
                                builder: (context, snapshot) {
                                  final useFirestore = snapshot.data ?? false;
                                  return IconButton(
                                    icon: Icon(useFirestore
                                        ? Icons.cloud
                                        : Icons.cloud_off),
                                    onPressed: _toggleFirestore,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {},
                              ),
                            ],
                    );
                  },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final stall = stalls[index];
                      final mediaManager = stallBlocList[index];
                      return Column(
                        children: [
                          StreamBuilder<List<DataStall>>(
                            stream: homeBloc.useFirestore
                                ? mediaManager.mediaPathsStream
                                : mediaManager.mediaPathsStream,
                            builder: (context, snapshot) {
                              final fileCount =
                                  snapshot.data?.length.toString() ?? "0";
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 8.0),
                                child: StallCard(
                                  date: stall.date ?? "",
                                  title: stall.title ?? "",
                                  subtitle: stall.description ?? "",
                                  fileCount: fileCount,
                                  imageUrl: stall.imageUrl ?? "",
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => StallDetailScreen(
                                        stallIndex: index,
                                        stallName: stall.title ?? "",
                                        stallDate: stall.date ?? "",
                                        companyName: stall.description ?? "",
                                        files: fileCount,
                                        useFirestore: homeBloc.useFirestore,
                                      ),
                                    ));
                                  },
                                  useNetworkImage: homeBloc.useFirestore,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    childCount: stalls.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
