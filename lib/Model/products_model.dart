
class ProductsModel {
  static const productsGraphQl = """
query products{
  products(first: 10, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail{
          url
        }
      }
    }
  }
}
""";

  final String name , desc , image;


  const ProductsModel({
    required this.name ,
    required this.desc ,
    required this.image ,
  });

  factory ProductsModel.fromApp(Map<String,dynamic>map){
    return ProductsModel(
        name: map['products']['edges']['node']['name'] ,
        desc: map['products']['edges']['node']['description'] ,
        image: map['products']['edges']['node']['thumbnail']['url'] ,
    );
  }


}