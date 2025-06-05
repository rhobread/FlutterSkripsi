import 'dart:math';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:workout_skripsi_app/service/HomeService/workoutDetails_service.dart';
import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/view/HomeView/main_view.dart';

// Main Workout Details Page
class WorkoutDetailsPage extends StatefulWidget {
  final String day;
  final int workoutId;
  final bool isToday;
  final bool isDone;

  const WorkoutDetailsPage({
    super.key,
    required this.day,
    required this.workoutId,
    required this.isToday,
    required this.isDone,
  });

  @override
  _WorkoutDetailsPageState createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  final WorkoutdetailsService workoutService = WorkoutdetailsService();
  final userController = Get.find<UserController>();

  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  bool _started = false;
  bool _isSaving = false;
  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final data = await workoutService.fetchWorkout(
      workoutId: widget.workoutId,
      isDone: widget.isDone,
    );
    setState(() {
      _exercises = data
          .map((e) => {
                'exercise': e,
                'sets': List<Map<String, dynamic>>.from(e['sets'] as List)
              })
          .toList();
      _expanded = List.filled(_exercises.length, false);
      _isLoading = false;
    });
  }

  Future<void> _finishWorkout() async {
    setState(() => _isSaving = true);
    final userId = int.tryParse(userController.userId.value.toString()) ?? 0;
    final success = await workoutService.finishWorkout(
      userId: userId,
      workoutId: widget.workoutId,
      exercises: _exercises,
    );
    setState(() => _isSaving = false);
    showSnackBarMessage('success'.tr, 'workout_done'.tr, success: true);
    if (success) Get.offAll(() => MainPage());
  }

  bool get _canEdit => !widget.isDone && widget.isToday && _started;

  void _showDetailSheet(int exerciseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetailSheetContent(exerciseId: exerciseId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.day,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, i) {
                      final ex =
                          _exercises[i]['exercise'] as Map<String, dynamic>;
                      final sets =
                          _exercises[i]['sets'] as List<Map<String, dynamic>>;
                      final isWeight = ex['type'] == 'weight';
                      final exerciseId = ex['exercise_id'] as int;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showDetailSheet(exerciseId),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        ex['image'] as String,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(
                                          () => _expanded[i] = !_expanded[i]),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex['name'] as String,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'type'.tr + ': ${ex['type']}',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _expanded[i] = !_expanded[i]),
                                    child: Icon(
                                      _expanded[i]
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_expanded[i])
                              Column(
                                children: sets.map((s) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          s['set_number'].toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (isWeight) ...[
                                          _buildBox(s['weight_used'],
                                              (v) => s['weight_used'] = v),
                                          const Text('KG',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                        _buildBox(
                                            s['reps'], (v) => s['reps'] = v),
                                        const Text('Reps',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (!widget.isDone && widget.isToday)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildCustomButton(
                      label: _started
                          ? 'finish_workout'.tr
                          : 'start_workout_session'.tr,
                      isLoading: _isSaving,
                      onPressed: _isSaving
                          ? null
                          : _started
                              ? _finishWorkout
                              : () {
                                  setState(() {
                                    _started = true;
                                    _expanded =
                                        List.filled(_exercises.length, true);
                                  });
                                },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildBox(dynamic initial, Function(int?) onChanged) {
    final enabled = _canEdit;
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        border: enabled ? Border.all(color: Colors.black, width: 1.5) : null,
      ),
      child: TextFormField(
        enabled: enabled,
        initialValue: initial?.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey[600]),
        decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8)),
        keyboardType: TextInputType.number,
        onChanged: (v) => onChanged(int.tryParse(v)),
      ),
    );
  }
}

// Detail Sheet Content
class DetailSheetContent extends StatefulWidget {
  final int exerciseId;
  final bool isHistory;
  const DetailSheetContent(
      {super.key, required this.exerciseId, this.isHistory = false});

  @override
  _DetailSheetContentState createState() => _DetailSheetContentState();
}

class _DetailSheetContentState extends State<DetailSheetContent> {
  final WorkoutdetailsService workoutService = WorkoutdetailsService();
  final userController = Get.find<UserController>();
  late final Future<Map<String, dynamic>?> descriptionFuture;
  late final Future<List<Map<String, dynamic>>> recordsFuture;

  @override
  void initState() {
    super.initState();
    descriptionFuture =
        workoutService.getDescription(exerciseId: widget.exerciseId);

    recordsFuture = descriptionFuture.then((ex) {
      if (ex == null) return <Map<String, dynamic>>[];

      final userId = int.tryParse(userController.userId.value.toString()) ?? 0;

      // Safely pull out 'exercise_cd' (default to empty string if null)
      final exerciseCd = (ex['exercise_cd'] as String?) ?? '';

      return workoutService.getExerciseRecords(
        userId: userId,
        exerciseCd: exerciseCd,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: descriptionFuture,
          builder: (c, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final ex = snap.data;
            if (ex == null) {
              return const Center(child: Text('Error loading details'));
            }

            // Safely pull out 'types' as a List<String>
            final types = (ex['types'] as List<dynamic>?)
                    ?.map((e) => (e as String? ?? '').trim())
                    .where((s) => s.isNotEmpty)
                    .toList() ??
                <String>[];

            final description = (ex['description'] ?? '').toString();

            // Safely pull out 'name', 'image', etc.
            final rawName = (ex['name'] as String?) ?? '';
            final name =
                widget.isHistory ? rawName.split('(').first.trim() : rawName;
            final imagePath = (ex['image'] as String?) ?? '';
            final equipment =
                types.contains('weight') ? 'item_weight'.tr : 'body_weight'.tr;
            final hasDescription = description.trim().isNotEmpty;

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: Colors.black,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'instructions'.tr),
                            Tab(text: 'records'.tr),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // -------------------------------------------------
                              // INSTRUCTIONS TAB
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imagePath.isNotEmpty)
                                      Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.asset(
                                            imagePath,
                                            fit: BoxFit.contain,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    if (hasDescription)
                                      MarkdownBody(
                                        data: description,
                                        styleSheet:
                                            MarkdownStyleSheet.fromTheme(
                                          Theme.of(context),
                                        ).copyWith(
                                          h1: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                          h2: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          p: const TextStyle(fontSize: 16),
                                        ),
                                      )
                                    else ...[
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (types.isNotEmpty) ...[
                                        Text(
                                          'type'.tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          types.join(', '),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Text(
                                        'equipments'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        equipment,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // -------------------------------------------------
                              // RECORDS TAB
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: recordsFuture,
                                builder: (c2, rsnap) {
                                  if (rsnap.connectionState !=
                                      ConnectionState.done) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final records = rsnap.data;
                                  if (records == null || records.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'no_records_yet'.tr,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: records.length,
                                    itemBuilder: (_, idx) {
                                      final rec = records[idx];

                                      // Safely extract 'reps' and convert each to int (default 0)
                                      final reps = (rec['reps']
                                                  as List<dynamic>?)
                                              ?.map((v) {
                                            if (v == null) return 0;
                                            if (v is num) return v.toInt();
                                            // in case the backend sent a string number
                                            return int.tryParse(v.toString()) ??
                                                0;
                                          }).toList() ??
                                          <int>[];

                                      // Safely extract 'weight_used' and convert each to int (default 0)
                                      final weights = (rec['weight_used']
                                                  as List<dynamic>?)
                                              ?.map((v) {
                                            if (v == null) return 0;
                                            if (v is num) return v.toInt();
                                            return int.tryParse(v.toString()) ??
                                                0;
                                          }).toList() ??
                                          <int>[];

                                      // Safely extract 'sets_done' (default to reps.length)
                                      final setsDone =
                                          (rec['sets_done'] as int?) ??
                                              reps.length;

                                      // Safely extract 'date' and 'exercise_name'
                                      final dateStr =
                                          (rec['date'] as String?) ?? '';
                                      final exerciseName =
                                          (rec['exercise_name'] as String?) ??
                                              '';

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dateStr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              exerciseName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ...List.generate(
                                              // Only show as many sets as the smaller of setsDone or reps.length
                                              min(setsDone, reps.length),
                                              (i) {
                                                final isBodyweight =
                                                    weights.isEmpty;
                                                final repCount = reps[i];
                                                final weightVal = isBodyweight
                                                    ? 0
                                                    : (i < weights.length
                                                        ? weights[i]
                                                        : 0);

                                                final mainText = isBodyweight
                                                    ? '$repCount ${'repetition'.tr}${repCount > 1 ? 's' : ''}'
                                                    : '$weightVal kg × $repCount';

                                                final oneRm = isBodyweight
                                                    ? null
                                                    : ((weightVal *
                                                            (1 + repCount / 30))
                                                        .round());

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor:
                                                                Colors.black,
                                                            child: Text(
                                                              '${i + 1}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            mainText,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (oneRm != null)
                                                        Text(
                                                          '1RM = $oneRm kg',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: buildCustomButton(
                    label: 'done_capital'.tr,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
