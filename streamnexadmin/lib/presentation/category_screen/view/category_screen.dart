// // categories_screen.dart
// import 'package:flutter/material.dart';

// class CategoriesScreen extends StatefulWidget {
//   @override
//   _CategoriesScreenState createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen> {
//   List<Category> categories = [
//     Category('Action', 245, true),
//     Category('Comedy', 189, true),
//     Category('Drama', 321, true),
//     Category('Horror', 156, false),
//     Category('Sci-Fi', 98, true),
//     Category('Romance', 167, true),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Categories Management'),
//         automaticallyImplyLeading: false,
//         actions: [
//           ElevatedButton.icon(
//             onPressed: () => _showAddCategoryDialog(),
//             icon: Icon(Icons.add),
//             label: Text('Add Category'),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           ),
//           SizedBox(width: 16),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: ListView.builder(
//           itemCount: categories.length,
//           itemBuilder: (context, index) {
//             final category = categories[index];
//             return Card(
//               color: Colors.grey[850],
//               margin: EdgeInsets.only(bottom: 8),
//               child: ListTile(
//                 leading: Icon(
//                   Icons.category,
//                   color: category.isActive ? Colors.green : Colors.grey,
//                 ),
//                 title: Text(
//                   category.name,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text('${category.contentCount} items'),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Switch(
//                       value: category.isActive,
//                       onChanged: (value) {
//                         setState(() {
//                           categories[index].isActive = value;
//                         });
//                       },
//                       activeColor: Colors.red,
//                     ),
//                     PopupMenuButton(
//                       icon: Icon(Icons.more_vert, color: Colors.white),
//                       color: Colors.grey[800],
//                       itemBuilder: (context) => [
//                         PopupMenuItem(
//                           child: Text('Edit', style: TextStyle(color: Colors.white)),
//                           value: 'edit',
//                         ),
//                         PopupMenuItem(
//                           child: Text('Delete', style: TextStyle(color: Colors.red)),
//                           value: 'delete',
//                         ),
//                       ],
//                       onSelected: (value) {
//                         if (value == 'delete') {
//                           setState(() {
//                             categories.removeAt(index);
//                           });
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _showAddCategoryDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.grey[850],
//         title: Text('Add New Category', style: TextStyle(color: Colors.white)),
//         content: TextField(
//           decoration: InputDecoration(
//             labelText: 'Category Name',
//             labelStyle: TextStyle(color: Colors.grey),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Add'),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Category {
//   final String name;
//   final int contentCount;
//   bool isActive;

//   Category(this.name, this.contentCount, this.isActive);
// }