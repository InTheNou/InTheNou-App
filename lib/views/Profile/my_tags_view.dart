import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class MyTagsView extends StatefulWidget {

  @override
  _MyTagsViewState createState() => new _MyTagsViewState();

}

class _MyTagsViewState extends State<MyTagsView>
    with flux.StoreWatcherMixin<MyTagsView> {

  UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
    getMyTagsAction();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("My Tags"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => getMyTagsAction(),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _userStore.userTags,
          builder: (BuildContext context, AsyncSnapshot<List<Tag>> userTags) {

            if(userTags.hasError){
              return _buildErrorWidget(userTags.error);
            } else if (userTags.hasData){
              return _buildResultsWidget(userTags.data);
            } else {
              return _buildLoadingWidget();
            }
          },
        )
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error,
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
          ],
        ));
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 100,
                height: 100,
                child: CircularProgressIndicator()),
          ],
        ));
  }

  Widget _buildResultsWidget(List<Tag> userTags) {
    return ListView.builder(
        itemCount: userTags.length,
        itemBuilder: (context, index) {
          Tag _tag = userTags[index];
          return Card(
              key: ValueKey(_tag.UID),
              margin: EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _tag.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: Theme.of(context).textTheme.headline6.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 4.0)),
                      Text(
                          "Weight: ${_tag.weight}",
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.start,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => removeTagAction(),
                      )
                    ],
                  ),
                ),
              )
          );
        });
  }
}