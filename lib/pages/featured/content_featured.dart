import 'package:FlutterNews/domain/notice/notice.dart';
import 'package:FlutterNews/pages/datail/detail.dart';
import 'package:FlutterNews/pages/featured/featured_bloc.dart';
import 'package:FlutterNews/util/bloc_provider.dart';
import 'package:FlutterNews/widgets/erro_conection.dart';
import 'package:FlutterNews/widgets/pageTransform/intro_page_item.dart';
import 'package:FlutterNews/widgets/pageTransform/page_transformer.dart';
import 'package:flutter/material.dart';

class ContentFeaturedPage extends StatefulWidget{

  var errorConection = false;

  static Widget create(){
    return BlocProvider<FeaturedBloc>(
      bloc: FeaturedBloc(),
      child: ContentFeaturedPage(),
    );
  }

  final state = new _ContentFeaturedState();

  @override
  State<StatefulWidget> createState() {
    return state;
  }

}

class _ContentFeaturedState extends State<ContentFeaturedPage> with TickerProviderStateMixin{

  AnimationController animationController;

  FeaturedBloc bloc;

  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 350)
    );

  }
  @override
  Widget build(BuildContext context) {

    if(bloc == null) {

      bloc = BlocProvider.of<FeaturedBloc>(context);
      confBlocView(bloc);

    }

    return Stack(
      children: <Widget>[
        new GestureDetector(
          child: new Stack(
            children: <Widget>[
              new FadeTransition(
                opacity: animationController,
                child: new Container(
                  child: _buildFeatureds(bloc),
                ),
              ),
              _getProgress(bloc)
            ],
          ),
          onTap: (){
            bloc.clickShowDetail();
          },
        ),
        StreamBuilder(
          stream: bloc.error,
          initialData: false,
          builder: (BuildContext context, AsyncSnapshot snapshot){

            if(snapshot.data) {
              return ErroConection(tryAgain:(){
                bloc.load();
              });
            }else{
              return Container();
            }

          }
        )
      ],
    );
  }

  Widget _getProgress(FeaturedBloc bloc){

    return StreamBuilder(
      initialData: false,
      stream: bloc.progress,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.data){
          return new Container(
            child: new Center(
              child: new CircularProgressIndicator(),
            ),
          );
        }else{
          return new Container();
        }
      }
    );

  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _buildFeatureds(FeaturedBloc bloc) {

    return StreamBuilder(
      initialData: List<Notice>(),
      stream: bloc.noticies,
      builder: (BuildContext context, AsyncSnapshot snapshot){

        var _destaque = snapshot.data;

        return new PageTransformer(
            pageViewBuilder: (context, visibilityResolver) {
              return new PageView.builder(
                controller: new PageController(viewportFraction: 0.9),
                itemCount: _destaque.length,
                onPageChanged: (position) {
                  bloc.noticeSelected(_destaque[position]);
                },
                itemBuilder: (context, index) {
                  final item = IntroNews.fromNotice(_destaque[index]);
                  final pageVisibility = visibilityResolver
                      .resolvePageVisibility(index);
                  return new IntroNewsItem(
                      item: item, pageVisibility: pageVisibility);
                },
              );
            }
        );

      }
    );

  }

  void confBlocView(FeaturedBloc bloc) {

    bloc.anim.listen((show){

      print(show);
      if(show){
        animationController.forward();
      }

    });

    bloc.detail.listen((notice){

      Navigator.of(context).push(
          new MaterialPageRoute(builder: (BuildContext context) {
            return new DetailPage(notice.img,notice.title,notice.date,notice.description,notice.category,notice.link,notice.origin);
          }
          )
      );

    });

    bloc.load();

  }

}

