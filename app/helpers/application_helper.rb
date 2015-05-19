module ApplicationHelper

  def get_cf_items(recommender)
    values = recommender['hits']['hits'].first['_source']['items']

    results = []

    values.each do |v|
      movie = Movie.where(id:  v['item']['system_id'].to_s).first
      results << [movie, v['value']]
    end
    results
  end

  def get_items(recommender)
    values = recommender['hits']['hits']

    results = {}

    values.each do |v|
      part = {}
      part[:value] = v['_source']['value']
      part[:name] = v['_source']['name']
      part[:reazon] = v['highlight']
      results[v['_source']['item_id']] = part
    end

    results
  end

  def ramdom_user_image
    "http://api.randomuser.me/portraits/thumb/#{[:women, :men].sample}/#{(0..50).to_a.sample}.jpg"
  end

  def select_similarity
    if params[:similarity]
      [params[:similarity].capitalize, params[:similarity]]
    else
      ['Pearson','pearson']
    end
  end

  def select_neigborhood
    if params[:neigborhood]
      [params[:neigborhood], params[:neigborhood]]
    else
      [5,5]
    end

  end

  def get_ir_recommender_result(result=nil)
    result['hits']['hits'].first['_source']['evaluation']
  end

  def get_rsme_recomender_result(result=nil)
    result['hits']['hits'].first['_source']['evaluation']
  end

  def parse_tags
    tags= {}

    @tags.each do |t|
      tag = t['_source']['item_id']
      tags[tag] ||= []
      tags[tag] << t['_source']['tag']
    end
    tags
  end
end
