import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/todo.dart';

class ItemTodoList extends StatefulWidget {
  ItemTodoList({Key? key, required this.todo, required this.onDelete, required this.onUpdate, required this.onComplete}) : super(key: key);
  final Todo todo;
  final Function onDelete;
  final Function onUpdate;
  final Function onComplete;

  @override
  State<ItemTodoList> createState() => _ItemTodoListState();
}

class _ItemTodoListState extends State<ItemTodoList> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Slidable(
          actionPane: SlidableStrechActionPane(),
          actions: [
            IconSlideAction(
              color: Color.fromRGBO(0x16, 0xCB, 0xE0, 1),
              icon: Icons.create,
              onTap: (){
                setState(() {
                  widget.onComplete(widget.todo);
                  print(widget.todo.complete);
                });
              },
            ),
          ],
          secondaryActions: [
            //Apagar
            IconSlideAction(
              color: Colors.red,
              icon: Icons.delete,
              caption: 'Deletar',
              onTap: (){
                widget.onDelete(widget.todo);
              },
            ),
            //Editar
            IconSlideAction(
              icon: Icons.edit,
              color: Colors.green,
              caption: 'Editar',
              onTap: (){
                widget.onUpdate(widget.todo);
              },
            ),
            IconSlideAction(
              icon: Icons.share,
              color: Color.fromRGBO(0x16, 0xCB, 0xE0, 1),
              caption: 'Compartilhar',
              onTap: (){
                share(context, widget.todo);
              },
            ),
          ],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.todo.complete ?  Color.fromRGBO(0x16, 0xCB, 0xE0, 1)
                : Colors.grey[300],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${DateFormat('dd/MM/yyyy - HH:mm').format(widget.todo.dataTime)}  -  ${widget.todo.complete ? 'Concluido' : 'A fazer'}',
                  style: const  TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                ),
                Text(widget.todo.title, style: const TextStyle(fontWeight: FontWeight.w700),),
              ],
            ),
          ),
      ),
    );
  }
  void share(BuildContext context, Todo todo){
    final RenderObject? box = context.findRenderObject();
    final String text = "🗒️ ${todo.title} - ${DateFormat('dd/MM/yyyy - HH:mm').format(todo.dataTime)}, Status: ${todo.complete ? 'Concluída': 'Pendente'}";

    Share.share(
  text,
    );
  }
}