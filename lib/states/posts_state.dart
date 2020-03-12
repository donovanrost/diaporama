import 'dart:async';
import 'package:diaporama/models/content_source.dart';
import 'package:diaporama/services/reddit_client_service.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class PostsState with ChangeNotifier {
  final RedditClientService redditService;

  PostsState({@required this.redditService});

  StreamController<UserContent> streamController;
  List<Submission> _contents = [];
  bool _isLoading = false;
  ContentSource _selectedSource;

  List<ContentSource> contentSources = [
    ContentSource(label: "Front Page", name: "frontpage"),
    ContentSource(label: "Popular", name: "popular"),
    ContentSource(label: "ImGoingToHellForThis", name: "imgoingtohellforthis"),
  ];

  List<Submission> get contents => List.from(_contents);
  bool get isLoading => _isLoading;

  void loadPosts({
    ContentSource source,
    int limit = 20,
  }) {
    setBusy();
    streamController = StreamController.broadcast();
    _contents.clear();
    _setSelectedSource(source);
    notifyListeners();

    streamController.stream.listen((post) {
      _contents.add(post);
    }, onDone: () {
      setBusy(value: false);
    });

    switch (source.name) {
      case "frontpage":
        redditService.reddit.front.hot(limit: limit).pipe(streamController);
        break;
      default:
        redditService.reddit
            .subreddit(source.name)
            .hot(limit: limit)
            .pipe(streamController);
        break;
    }
  }

  void setBusy({bool value = true}) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSelectedSource(ContentSource source) {
    _selectedSource = source;
    notifyListeners();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
}
