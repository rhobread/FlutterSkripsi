import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/InitialService/pickgoal_service.dart';

class PickGoalPage extends StatefulWidget {
  const PickGoalPage({super.key});

  @override
  _PickGoalPageState createState() => _PickGoalPageState();
}

class _PickGoalPageState extends State<PickGoalPage> {
  late PickGoalController _controller;
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _controller = PickGoalController(userController.userId.value, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMainHeader(context: context),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Pick your goal!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Used to generate your routines, won\'t be shared!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  for (int i = 0; i < _controller.goals.length; i++)
                    buildSelectOption(
                      title: _controller.goals[i],
                      isSelected: _controller.selectedGoal == i,
                      onPressed: () => setState(() {
                        _controller.selectGoal(i);
                      }),
                    ),
                  const SizedBox(height: 20),
                  buildCustomButton(
                    label: 'Continue',
                    isLoading: _controller.isLoading,
                    onPressed:
                        _controller.selectedGoal == -1 || _controller.isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _controller.isLoading = true;
                                });
                                await _controller.continueNextPage();
                                setState(() {
                                  _controller.isLoading = false;
                                });
                              },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          buildMainFooter(),
        ],
      ),
    );
  }
}
