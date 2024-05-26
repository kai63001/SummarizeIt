import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumarizeit/store/recording_store.dart';

class CustomBottomSheet extends StatelessWidget {
  final BuildContext parentContext;

  const CustomBottomSheet({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: parentContext,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.3, // Initial height of the Sheet
            minChildSize: 0.1, // Minimum height of the Sheet
            maxChildSize: 1, // Maximum height of the Sheet
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF14141A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: BlocBuilder<RecordingStore, List<Map<String, dynamic>>>(
                  builder: (context, state) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.isEmpty ? 1 : state.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (state.isEmpty) {
                          return const ListTile(title: Text('No recording'));
                        }
                        return ListTile(
                            title: Text(state[index]['name'] ?? 'No title',
                                style: const TextStyle(color: Colors.white)),
                            subtitle: _buildTimer(
                                int.parse(state[index]['duration'].toString())),
                            trailing: const Icon(Icons.info),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            onTap: () => Navigator.pushNamed(
                                parentContext, '/record-audio',
                                arguments: state[index]['path'] ?? 'No path'));
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      icon: const Icon(Icons.list_alt),
    );
  }

  Widget _buildTimer(int recordDuration) {
    final String minutes = _formatNumber(recordDuration ~/ 60);
    final String seconds = _formatNumber(recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }
}
