import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumarizeit/page/summary_done.dart';
import 'package:sumarizeit/store/history_store.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: BlocBuilder<HistoryStore, List<Map<String, dynamic>>>(
            builder: (context, state) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: state.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryDone(
                        text: state[index]['summary'],
                        type: state[index]['type'],
                        title: state[index]['title'],
                        done: true,
                        historyId: state[index]['id'],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 20.0 : 0),
                  child: Card(
                    child: ListTile(
                      title: Text(state[index]['title']),
                      subtitle: Text(
                          '${state[index]['summary'].toString().length >= 50 ? state[index]['summary'].toString().substring(0, 50) : state[index]['summary'].toString()}...'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }
}
