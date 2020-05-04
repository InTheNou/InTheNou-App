import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/stores/event_creation_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// A custom Widget for selecting Tags
///
/// {@category Widget}
class TagSelectionWidget extends StatefulWidget {

  @override
  _TagSelectionWidgetState createState() => new _TagSelectionWidgetState();

}

class _TagSelectionWidgetState extends State<TagSelectionWidget>
    with flux.StoreWatcherMixin<TagSelectionWidget> {

  EventCreationStore _creationStore;

  @override
  void initState() {
    super.initState();
    _creationStore = listenToStore(EventCreationStore.eventCreationStoreToken);
    getAllTagsAction();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: <Widget>[
              const Padding(padding: EdgeInsets.all(8.0)),
              Icon(Icons.search),
              const Padding(padding: EdgeInsets.only(
                  left: 16.0)),
              Expanded(
                child: TextField(
                  decoration: InputDecoration.collapsed(
                      hintText:  "Search Tags",),
                  onChanged: (String value) => searchedTagAction(value)
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: kElevationToShadow[2]
          ),
          constraints: BoxConstraints(
              maxHeight: 500.0,
              minHeight: 50.0),
          child: Scrollbar(
            child: ListView.builder(
                itemCount: _creationStore.searchTags.keys.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index){
                  MapEntry<Tag,bool> tag = _creationStore.searchTags
                      .entries.elementAt(index);
                  return CheckboxListTile(
                    title: Text(tag.key.name),
                    value: tag.value,
                    onChanged: (bool value){
                      selectedTagAction(MapEntry(tag.key, value));
                    },
                  );
                }),
          ),
        )
      ],
    );
  }
}