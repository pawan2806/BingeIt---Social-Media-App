import 'package:cached_network_image/cached_network_image.dart';
import 'package:bingeit/application/auth/sign_in_form/edit_profile/edit_profile_bloc.dart';
import 'package:bingeit/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_information_bloc.dart';
import 'package:bingeit/constants.dart';
import 'package:bingeit/data/models/our_user/our_user.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final OurUser ourUser;

  EditProfilePage({@required this.ourUser});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _debouncer = Debouncer(milliseconds: 500);
  TextEditingController _usernameController;
  TextEditingController _fullNameController;
  TextEditingController _bioController;
  bool isChecked = false;

  Widget getUsernameStatusIcon({SignInFormState state, String value}) {
    if (widget.ourUser.username == value) {
      isChecked = true;
      return Icon(
        Icons.check,
        color:Colors.greenAccent,
      );
    }

    if (state.isUserTypingUsername) {
      isChecked = false;
      return Icon(null);
    } else {
      if (state.isUsernameAvailable) {
        isChecked = true;
        return Icon(
          Icons.check,
          color:Colors.greenAccent,
        );
      } else {
        isChecked = false;
        return Icon(
          Icons.clear,
          color: Colors.red,
        );
      }
    }
  }

  bool checkUsername({SignInFormState state, String value}) {
    if (value == widget.ourUser.username || state.isUsernameAvailable) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.ourUser.username);
    _fullNameController = TextEditingController(text: widget.ourUser.fullName);
    _bioController = TextEditingController(text: widget.ourUser.bio);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF1B1E2B),
      body: SafeArea(

        child: BlocConsumer<EditProfileBloc, EditProfileState>(

          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              if (state.errorMessage == kSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Successfully updated profile"),
                    duration: Duration(seconds: 1),
                  ),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 32,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  BlocBuilder<CurrentUserProfileInformationBloc,
                      CurrentUserProfileInformationState>(
                    builder: (context, currentUserState) {
                      return GestureDetector(
                        onTap: () {
                          context.read<CurrentUserProfileInformationBloc>().add(
                                CurrentUserProfileInformationEvent
                                    .uploadProfilePhotoPressed(),
                              );
                        },
                        child: _profilePhoto(currentUserState),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<CurrentUserProfileInformationBloc>().add(
                            CurrentUserProfileInformationEvent
                                .uploadProfilePhotoPressed(),
                          );
                    },
                    style:
                        TextButton.styleFrom(primary: Color(0xFF6398ff),),
                    child: Text(
                        "Change Profile Photo",
                      style: TextStyle(
                        fontSize: 16,
                      ),

                    ),
                  ),
                  if (state.isSubmitting) LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      autocorrect: false,
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                      ),
                    ),
                  ),
                  BlocBuilder<SignInFormBloc, SignInFormState>(
                    builder: (context, signInFormState) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          inputFormatters: [
                            // FilteringTextInputFormatter.allow(
                            //   RegExp("[0-9a-zA-Z]"),
                            // ),
                            FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
                            LengthLimitingTextInputFormatter(30),

                          ],
                          autocorrect: false,
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            suffixIcon: getUsernameStatusIcon(
                              state: signInFormState,
                              value: _usernameController.text.toLowerCase(),
                            ),
                          ),
                          onChanged: (value) {
                            context.read<SignInFormBloc>().add(
                                  SignInFormEvent.usernameChanged(),
                                );
                            _debouncer.run(() {
                              context.read<SignInFormBloc>().add(
                                    SignInFormEvent.usernameBeingChecked(value),
                                  );
                            });
                          },
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      maxLength: 150,
                      autocorrect: false,
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BlocBuilder<SignInFormBloc, SignInFormState>(
                        builder: (context, signInFormState) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: FloatingActionButton(

                                child: const Icon(
                                    Icons.check_circle_outline,
                                  size: 35,
                                ),
                                backgroundColor:  Colors.greenAccent,

                                onPressed: () {
                                  if (isChecked)
                                    context.read<EditProfileBloc>().add(
                                      EditProfileEvent
                                          .confirmEditProfilePressed(
                                        fullName:
                                        _fullNameController.text.trim(),
                                        bio: _bioController.text.trim(),
                                        username: _usernameController.text,
                                        isUsernameAvailable: checkUsername(
                                          value: _usernameController.text,
                                          state: signInFormState,
                                        ),
                                      ),
                                    );
                                }
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profilePhoto(CurrentUserProfileInformationState state) {
    if (state.isUploadingPhoto || state.isSearching) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: state.ourUser.profilePhotoUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          foregroundImage: imageProvider,
          backgroundColor: Colors.black,
          radius: 60,
        ),
        placeholder: (context, url) => Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          return state.ourUser.profilePhotoUrl.isEmpty
              ? CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    'Add\nImage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff476072),
                        fontWeight: FontWeight.bold
                    ),),
                  radius: 60,
                )
              : CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.error, color: Colors.white),
                  radius: 60,
                );
        },
      );
    }
  }
}
