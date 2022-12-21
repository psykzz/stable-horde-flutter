import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stable_horde_flutter/blocs/shared_prefs_bloc.dart';
import 'package:stable_horde_flutter/blocs/stable_horde_bloc.dart';
import 'package:stable_horde_flutter/model/stable_horde_model.dart';

class ModelChooserPage extends StatelessWidget {
  const ModelChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF230D49),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Models"),
      ),
      body: FutureBuilder<List<StableHordeModel>>(
        future: stableHordeBloc.getModels(),
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
          var models = snapshot.data ?? [];

          return ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return GestureDetector(
                onTap: () async {
                  await sharedPrefsBloc.setModel(model.name);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: SizedBox(
                    height: 128,
                    child: Row(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: CachedNetworkImage(
                            imageUrl: model.previewImageUrl,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "${model.workerCount} worker${model.workerCount == 1 ? "" : "s"}"),
                                const SizedBox(height: 4),
                                Text(model.description),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}