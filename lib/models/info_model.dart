class Info {
  final String imageUrl;
  final String name;
  final String category;

  Info({
    this.imageUrl,
    this.name,
    this.category,

  });
}

final List<Info> infos = [
  Info(
    imageUrl: 'assets/images/info0.jpg',
    name: 'Login',
    category: 'Already a member ?',
  ),
  Info(
    imageUrl: 'assets/images/info1.jpg',
    name: 'Sign Up',
    category: 'New to our app ?',
  ),
];
