import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'property.dart';

class Search extends SearchDelegate{
  Widget _image (String url, Size screenSize){
			if(url == ''){
        return SizedBox(
          height: 150,
				  width: screenSize.width/2.5,
          child: ClipRect(child:Image.asset("no_img.png", fit: BoxFit.fill,)),
        );
      }
      return new SizedBox(
        height: 150,
				width: screenSize.width/2.5,
				child: ClipRect(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.fill,
              ),
            ),
          ),
			  ),
      );
	}

	Widget _listItemBuilder (BuildContext context , DocumentSnapshot snapshot, Size screenSize){
		return SizedBox(
      height: 150,
      width: screenSize.width,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
            children: <Widget>[
              ListTile(
                leading: Container(
                  child: snapshot['photo'].length<1 || snapshot['photo']==null ? _image('',screenSize) 
                        :_image(snapshot['photo'][0], screenSize),
                ),
                title: Text("${snapshot['name'][0].toUpperCase()}${snapshot['name'].substring(1).toLowerCase()}" ),
                subtitle: snapshot['description'].length>20? Text("${snapshot['description'].substring(0,20)}..."):Text(snapshot['description']),
                onTap: (){
                  Route route = MaterialPageRoute(builder: (context)=> PropertyPage(snapshot.documentID));
                  Navigator.of(context).push(route);
  
                },
            ),
          ],
        ),
      ),	
    );	
	}

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: (){
        close(context, null);
      },
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    List<String> queryKeys = query.toLowerCase().split(" ");
    return StreamBuilder( 
        stream: Firestore.instance.collection('Property').snapshots(),
				// stream: searchResult(query),
				builder: (context, snapshot){

              Size screenSize = MediaQuery.of(context).size;
              if(!snapshot.hasData ) return new Center(
                child: new CircularProgressIndicator(),
              );
              print(snapshot.data.documents.length);
              print(query);
              var temp =[];
              for (var doc in snapshot.data.documents) {
                if(queryKeys.contains( doc['name'].toLowerCase())){
                  temp.add(doc);
                  continue;
                }
                for (var item in doc['tags']) {
                  if(queryKeys.contains(item.toLowerCase())){
                    temp.add(doc);
                    break;
                  } 
                }
                  
              }
              return new ListView.builder(
                padding: EdgeInsets.all(2),
                itemExtent: 140,
                itemCount: temp.length,
                itemBuilder: (context, index) => _listItemBuilder(context, temp[index], screenSize),
              );
            },
          ); 
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}