import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stable_horde_flutter/blocs/stable_horde_bloc.dart';
import 'package:stable_horde_flutter/colors.dart';
import 'package:stable_horde_flutter/model/stable_horde_task.dart';
import 'package:stable_horde_flutter/pages/fullscreen_view_page.dart';
import 'package:stable_horde_flutter/widgets/task_progress_indicator.dart';

class MyArtTab extends StatefulWidget {
  const MyArtTab({super.key});

  @override
  State<MyArtTab> createState() => _MyArtTabState();
}

class _MyArtTabState extends State<MyArtTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<StableHordeTask>>(
      stream: stableHordeBloc.getTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.stackTrace);

          Sentry.captureException(
            snapshot.error,
            stackTrace: snapshot.stackTrace,
          );
        }
        var tasks = snapshot.data ?? [];

        tasks = tasks.reversed.toList();

        return GridView.builder(
          itemCount: tasks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final task = tasks[index];

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullScreenViewPage(initialIndex: index),
                  ),
                );
              },
              child: Stack(
                children: [
                  const FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: ColoredBox(color: stableHordeGrey),
                  ),
                  if (task.imagePath != null)
                    Image.file(
                      File(task.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  TaskProgressIndicator(task),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}