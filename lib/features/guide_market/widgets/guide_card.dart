import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class GuideCard extends StatelessWidget{
final Map<String,dynamic> guide;
final VoidCallback onTap;

const GuideCard({super.key,required this.guide,required this.onTap});

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
return Card(
margin:const EdgeInsets.only(bottom:12),
shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
child:Padding(
padding:const EdgeInsets.all(12.0),
child:Column(
children:[
Row(
children:[
const CircleAvatar(radius:25,child:Icon(Icons.person)),
const SizedBox(width:12),
Expanded(
child:Column(
crossAxisAlignment:CrossAxisAlignment.start,
children:[
Row(
children:[
Text(guide['name'],style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)),
const SizedBox(width:5),
const Icon(Icons.workspace_premium,color:Colors.black,size:18),
],
),
Text("${l10n.rating}: ${guide['rating']} • ${l10n.experience}: ${guide['exp']}"),
const SizedBox(height: 5),
Row(
  children: [
    Text("${l10n.languages} ", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
    Expanded(
      child: Text(
        (guide['languages'] as List).join(" • "), 
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),
],
),
),
IconButton(
icon:Icon(Icons.info_outline,color:Theme.of(context).primaryColor),
onPressed:onTap,
),
],
),
],
),
),
);
}
}