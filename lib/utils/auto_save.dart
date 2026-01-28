import '../models/registration_data.dart';
import 'registration_draft.dart';

Future<void> autoSaveStep(RegistrationData data, int step) async {
  data.lastCompletedStep = step;
  await RegistrationDraft.save(data);
}
