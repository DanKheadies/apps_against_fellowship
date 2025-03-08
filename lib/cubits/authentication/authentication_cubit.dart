import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState.initial()) {
    // Note: this does trigger when the cubit is instantiated, i.e. when we
    // open the AuthenticationWidget via Login or Register. Does not repeat on
    // subsequent visits.
    // print('auth cubit!');
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        status: AuthenticationStatus.initial,
      ),
    );
  }

  void nameChanged(String value) {
    emit(
      state.copyWith(
        name: value,
        status: AuthenticationStatus.initial,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        status: AuthenticationStatus.initial,
      ),
    );
  }

  void signOut() {
    emit(
      AuthenticationState.initial(),
    );
  }
}
