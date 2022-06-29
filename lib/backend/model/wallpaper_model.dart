class Photos{
  int? id;
  int? width;
  int? height;
  String? url;
  String? photographer;
  String? photographer_url;
  int? photographer_id;
  String? avg_color;
  Src src;
  String? alt;
  Photos(this.id,this.width,this.height,this.url, this.photographer,this.photographer_url,this.photographer_id,this.avg_color,this.src, this.alt);
  factory Photos.fromJson(Map<String,dynamic> photos){
    return Photos(photos['id'], photos['width'], photos['height'], photos['url'], photos['photographer'],
        photos['photographer_url'], photos['photographer_id'], photos['avg_color'], Src.fromJson(photos['src']), photos['alt']);
  }

}

class Src{
  String? portrait;
  String? original;
  String? landscape;
  Src(this.portrait, this.original, this.landscape);
  factory Src.fromJson(Map<String,dynamic> src){
    return Src(src['portrait'], src['original'], src['landscape']);
  }
}