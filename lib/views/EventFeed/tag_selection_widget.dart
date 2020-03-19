import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/stores/event_creation_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

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
    _creationStore = listenToStore(eventCreationStoreToken);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: kElevationToShadow[2],
              borderRadius: BorderRadius.circular(16.0)
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
                      hintText:  "Serach Tags",),
                  onChanged: (String value) => searchedTagAction(value)
                ),
              ),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.all(4.0)),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: kElevationToShadow[2]
          ),
          height: 500.0,
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