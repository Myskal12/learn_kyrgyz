class Constants {
  static const appName = 'English from Kyrgyz';
  static const postLogoutRedirectKey = 'post_logout_redirect_to_login';
  static const disableEmailVerification = bool.fromEnvironment(
    'DISABLE_EMAIL_VERIFICATION',
    defaultValue: false,
  );
}
