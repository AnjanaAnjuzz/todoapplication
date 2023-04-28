import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('shopping_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.yellow,


      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),

    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController =TextEditingController();
  final TextEditingController _quantityController =TextEditingController();
  List<Map<String,dynamic>>_items =[];
  final _shoppingBox =Hive.box('shopping_box');
  void initState(){
    super.initState();
    _refreshItems();
  }

  void _refreshItems(){
    final data =_shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }

      ).toList();
    setState(() {
      _items=data.reversed.toList();
      print(_items.length);
    });
  }

  Future<void> _createItem(Map<String,dynamic>newItem)async{
    await _shoppingBox.add(newItem);
 _refreshItems();
  }
  Future <void>_updateItem(int itemKey, Map<String,dynamic> item)async {
    await _shoppingBox.put(itemKey,item);
    _refreshItems();
  }
  Future<void> _deleteItem(int itemKey)async{
    await _shoppingBox.delete(itemKey);
    _refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An item has been deleted'))
    );
  }
  void _showform(BuildContext ctx, int? itemKey)async{

    if(itemKey !=null){
      final existingItem =
          _items.firstWhere((element) => element['key']==itemKey);
      _nameController.text=existingItem['name'];
      _quantityController.text= existingItem['quantity'];

    }
    showModalBottomSheet(context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=> Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15,

          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _quantityController,

                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: ()async{


               if(itemKey == null) {
                 _createItem({
                   "name": _nameController.text,
                   "quantity": _quantityController.text,

                 });
               }
                if(itemKey !=null){

                  _updateItem(itemKey, {
                    'name':_nameController.text.trim(),
                    'quantity':_quantityController.text.trim()
                  });
                }
                _nameController.text='';
                _quantityController.text='';
                Navigator.of(context).pop();

              },
                  child: Text(itemKey==null?'Create New':'Update'),
              ),
              SizedBox(height: 15,)

            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text('TO DO'),

      ),
      body: ListView.builder(
        itemCount: _items.length,

          itemBuilder: (_, index){
        final currentItem =_items[index];
        return Card(
          color: Colors.yellow.shade100,
          margin: const EdgeInsets.all(10),
          elevation: 3,
          child: ListTile(
            title: Text(currentItem['name']),
            subtitle: Text(currentItem['quantity'].toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(
            icon:const Icon(Icons.edit),
                    onPressed: ()=> _showform(context, currentItem['key']),

                ),
                IconButton(
                  icon:const Icon(Icons.delete),
                    onPressed: ()=> _deleteItem(currentItem['key']))


              ],
            ),
          ),

        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> _showform(context, null),
        child: const Icon(Icons.add),

      ),
    );
  }
}

