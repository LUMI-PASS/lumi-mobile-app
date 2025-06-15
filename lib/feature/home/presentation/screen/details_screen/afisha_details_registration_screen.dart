import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_register_cubit/afisha_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_register_cubit/afisha_state.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class AfishaRegistrationScreen extends StatefulWidget {
  final AfishaData afishaData;
  final String uerId;

  const AfishaRegistrationScreen({
    required this.afishaData,
    required this.uerId,
    super.key,
  });

  @override
  AfishaRegistrationScreenState createState() =>
      AfishaRegistrationScreenState();
}

class AfishaRegistrationScreenState extends State<AfishaRegistrationScreen> {
  String? selectedDateOfBirth;
  String? selectedChessLevel;
  DateTime? pickedDate;

  final Map<String, String> chessLevels = {
    'Havaskor': 'amateur',
    'Profesional': 'professional',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.greyG20,
      appBar: AppBar(
        backgroundColor: ChessColors.greyG20,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ChessColors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocProvider(
        create: (context) => getIt<AfishaRegistrationCubit>(),
        child: BlocListener<AfishaRegistrationCubit, AfishaRegistrationState>(
          listener: (context, state) {
            if (state is AfishaRegistrationSuccess) {
              context.router.replace(const AfishaResultRoute());
            } else if (state is AfishaRegistrationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Xatolik")),
              );
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ro’yxatdan o’tish",
                  style: context.textTheme.largeTitle3Bold.copyWith(
                    color: ChessColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  title: 'Tug\'ilgan kuningiz',
                  value: selectedDateOfBirth,
                  items: const [], // This will be handled in the onTap
                  onChanged: (value) {},
                  onTap: () => _showDatePicker(context),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  title: 'Shaxmatdagi darajangiz',
                  value: selectedChessLevel != null
                      ? chessLevels.keys.firstWhere(
                          (k) => chessLevels[k] == selectedChessLevel,
                          orElse: () => 'Shaxmatdagi darajangiz',
                        )
                      : 'Shaxmatdagi darajangiz',
                  items: chessLevels.keys.toList(), // Example levels
                  onChanged: (value) {
                    setState(() {
                      selectedChessLevel = chessLevels[value];
                    });
                  },
                  onTap: null,
                ),
                const Spacer(),
                BlocBuilder<AfishaRegistrationCubit, AfishaRegistrationState>(
                  builder: (context, state) {
                    if (state is AfishaRegistrationLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ChessButton.primary(
                      onPressed: () async {
                        final id = widget.afishaData.id;
                        final dob =
                            DateFormat('yyyy-MM-dd').format(pickedDate!);
                        final level = selectedChessLevel!;

                        // Perform your registration logic
                        context.read<AfishaRegistrationCubit>().register(
                              id: id,
                              dob: dob,
                              level: level,
                            );
                      },
                      label: 'Tasdiqlash',
                      background: ChessColors.primaryDefault,
                      borderRadius: 16,
                      textStyle: context.textTheme.bodyMedium.copyWith(
                        color: ChessColors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    DateTime lastDate = DateTime(2020, 12, 31);
    DateTime initialDate = pickedDate ?? DateTime.now();

    // Ensure the initial date is within the valid range
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: MediaQuery.of(context).size.height * 0.40,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: CupertinoDatePicker(
            initialDateTime: initialDate,
            onDateTimeChanged: (DateTime date) {
              setState(() {
                pickedDate = date;
                selectedDateOfBirth =
                    DateFormat('dd MMMM yyyy', 'uz_UZ').format(date);
              });
            },
            mode: CupertinoDatePickerMode.date,
            maximumDate: lastDate,
            maximumYear: 2020,
          ),
        ),
      );
    } else {
      showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1900),
              lastDate: lastDate)
          .then((date) {
        if (date != null) {
          setState(() {
            pickedDate = date;
            selectedDateOfBirth =
                DateFormat('dd MMMM yyyy', 'uz_UZ').format(date);
          });
        }
      });
    }
  }

  void _showBottomSheet({
    required String title,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: context.textTheme.bodyRegular.copyWith(
                  color: ChessColors.greyG200,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      items[index],
                      style: context.textTheme.bodyRegular.copyWith(
                        color: ChessColors.black,
                      ),
                    ),
                    onTap: () {
                      onChanged(items[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String title,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            _showBottomSheet(
              title: title,
              items: items,
              onChanged: onChanged,
            );
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: ChessColors.greyG30,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? title,
              style: context.textTheme.bodyRegular.copyWith(
                color: ChessColors.greyG200,
              ),
            ),
            ChessUiKitAssets.icons.general.chevronDown.svg(
              colorFilter: const ColorFilter.mode(
                ChessColors.greyG400,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
