import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/HomeService/profiledetails_service.dart';
import 'package:workout_skripsi_app/service/InitialService/inputdata_service.dart';
import 'package:workout_skripsi_app/view/InitialView/pickequipment_view.dart';
import 'package:workout_skripsi_app/view/InitialView/pickavailability_view.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final profileService = ProfileDetailsService();
  final userController = Get.find<UserController>();
  String userId = "";
  var _userData;
  String availableEquipment = "1";
  String gender = "";
  String weight = "";
  String height = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      userId = userController.userId.value;
      final userData = await profileService.getUserDetails(userId: userId);
      if (!mounted) return;
      setState(() {
        _userData = userData;
        // initialize gender with localized first option
        weight = _userData['weight'].toString();
        height = _userData['height'].toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage('Failed!', e.toString());
    }
  }

  // runtime getter for localized gender options
  List<String> get genders => [
        'gender_male'.tr,
        'gender_female'.tr,
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(title: 'profile'.tr),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(
                  child: Text(
                    'failed_load_profile'.tr,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      buildSection(
                        'available_days'.tr,
                        [
                          buildSettingsTile(
                            context,
                            Icons.calendar_today,
                            'available_days'.tr,
                            Colors.blue,
                            onTap: () => Get.to(
                              () => const PickAvailabilityPage(
                                isUpdateAvailability: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      buildSection(
                        'available_equipments'.tr,
                        [
                          buildSettingsTile(
                            context,
                            Icons.fitness_center,
                            'available_equipments'.tr,
                            Colors.red,
                            onTap: () => Get.to(
                              () => const PickEquipmentPage(
                                isGymSelected: false,
                                isUpdateEquipment: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      buildSection(
                        'basic_info'.tr,
                        [
                          buildProfileItem(
                            context,
                            Icons.monitor_weight,
                            'weight'.tr,
                            '$weight kg',
                            Colors.green,
                            () {
                              showWeightBottomSheet(
                                context,
                                userId,
                                weight,
                                (newWeight) {
                                  setState(() {
                                    weight = newWeight;
                                  });
                                },
                                true,
                              );
                            },
                          ),
                          buildProfileItem(
                            context,
                            Icons.height,
                            'height'.tr,
                            height,
                            Colors.lightBlueAccent,
                            () {
                              showHeightBottomSheet(
                                context,
                                userId,
                                height,
                                (newHeight) {
                                  setState(() {
                                    height = newHeight;
                                  });
                                },
                                true,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
