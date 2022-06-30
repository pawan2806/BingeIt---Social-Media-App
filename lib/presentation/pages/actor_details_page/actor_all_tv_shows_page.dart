import 'package:bingeit/data/models/actor_details/actor_details.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/material.dart';

class ActorAllTvShowsPage extends StatefulWidget {
  final TvCredits tvCredits;
  final String actorName;

  ActorAllTvShowsPage({this.tvCredits, this.actorName});

  @override
  _ActorAllTvShowsPageState createState() => _ActorAllTvShowsPageState();
}

class _ActorAllTvShowsPageState extends State<ActorAllTvShowsPage> with TickerProviderStateMixin {
  TabController _tabController;
  final List<Tab> _myTabs = <Tab>[
    const Tab(text: "Cast"),
    const Tab(text: "Crew"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, vsync: this, length: _myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _tabViews(BuildContext context) {
    List<Widget> views = <Widget>[
      _buildCastTabView(context),
      _buildCrewTabView(context),
    ];
    return views;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFF1B1E2B),
          appBar: AppBar(

            title: Text(
              widget.actorName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: _myTabs,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabViews(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCastTabView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4.0,
        right: 4.0,
        top: 8.0,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.50,
        ),
        itemCount: widget.tvCredits.cast.length,
        itemBuilder: (context, index) {
          return _buildGridViewItem(context, index, true);
        },
      ),
    );
  }

  Widget _buildCrewTabView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4.0,
        right: 4.0,
        top: 8.0,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.50,
        ),
        itemCount: widget.tvCredits.crew.length,
        itemBuilder: (context, index) {
          return _buildGridViewItem(context, index, false);
        },
      ),
    );
  }

  //Added bool value isCast, so the same widget can be used for crew and cast, and doesn't need more redundant code
  Widget _buildGridViewItem(BuildContext context, int index, bool isCast) {
    String tvShowRating = _getTvShowRating(index, isCast);
    var tvShowSummary = isCast ? widget.tvCredits.cast[index].tvShowSummary : widget.tvCredits.crew[index].tvShowSummary;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(
              builder: (context) => TvShowDetailsPage(
                tvShowName: tvShowSummary.name,
                tvShowId: tvShowSummary.id,
              ),
            ),
          );
        },
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 0.65,
              child: BuildPosterImage(
                height: 135,
                width: 90,
                imagePath: tvShowSummary.posterPath,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Text(
                isCast
                      ?widget.tvCredits.cast[index].tvShowSummary.name
                      :widget.tvCredits.crew[index].tvShowSummary.name,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),

            ),
            Expanded(
              child: Text(
                isCast ? widget.tvCredits.cast[index].character : widget.tvCredits.crew[index].job,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTvShowRating(int index, bool isCast) {
    String returnString = "";
    var tvShowSummary = isCast ? widget.tvCredits.cast[index].tvShowSummary : widget.tvCredits.crew[index].tvShowSummary;
    tvShowSummary.voteCount > 100 && tvShowSummary.voteAverage != 0
        ? returnString = "⭐" + tvShowSummary.voteAverage.toString() + " "
        : returnString = "⭐ N/A ";
    return returnString;
  }
}
