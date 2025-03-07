import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState.initial()) {
    print('auth cubit!');
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
