import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


/// Dialog for adding Tags in the MyTags view
///
/// The user can add and remove these Tags
///
/// {@category View}
class AddTagDialog extends StatefulWidget {

  @override
  _AddTagDialogState createState() => new _AddTagDialogState();

}

class _AddTagDialogState extends State<AddTagDialog>
    with flux.StoreWatcherMixin<AddTagDialog> {
  UserStore _userStore;

  @override
  void initState() {
    _userStore = listenToStore(UserStore.userStoreToken);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).canvasColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0,0.0),
            child: Row(
              children: <Widget>[
                Text('Add a Tag',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: 400.0,
                  minHeight: 50.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 0.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                        autofocus: false,
                        maxLength: 50,
                        maxLengthEnforced: true,
                        decoration: InputDecoration(
                            hintText: "Search Tags...",
                            border: InputBorder.none,
                            counterStyle: TextStyle(height: double.minPositive,),
                            counterText: ""
                        ),
                        onChanged: (String value) => filterTagAction(value)
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                    ),
                    Expanded(
                      child: Scrollbar(
                        child: Card(
                          child: ListView.builder(
                              itemCount: _userStore.filteredTags.entries.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index){
                                MapEntry<Tag,bool> tag = _userStore.filteredTags
                                    .entries.elementAt(index);
                                return CheckboxListTile(
                                  title: Text(tag.key.name),
                                  value: tag.value,
                                  onChanged: (bool value){
                                    selectTagAction(MapEntry(tag.key, value));
                                  },
                                );
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text("ADD"),
                onPressed: _userStore.addedTag == null ?
                  null : () async {
                  await addTagAction();
                },
              )
            ],
          ),
        ],
      ),

    );;
  }
}