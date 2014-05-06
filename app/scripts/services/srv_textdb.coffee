###
  Класс для работы с текстами
  Описание:

  Есть таблица-массив
  textDB = {
    'ef0ef818eb8f2d91c61dc4e105': {
      text: 'Texts string'
      diffs: [
        "sdas32dwed234", tm
      ]
      last_sync_text: ''
    }
  }

###
class TextDB
  @$inject: ['$timeout', '$q']
  constructor: (@timeout, @q)->
    console.info 'constructor textDB did'
    mythis = @;
    _.each @textToLoad, (txt, key)->
      console.info 'sha of txt = ', key
      sha = mythis.sha(txt);
      mythis.textDB[key] = { text: txt, sha: sha }
  textToLoad: {
    '5353a5a9265932b16f11ff24': 'South America (Spanish: América del Sur, Sudamérica or  \n' +
                'Suramérica; Portuguese: América do Sul; Quechua and Aymara:  \n' +
                'Urin Awya Yala; Guarani: Ñembyamérika; Dutch: Zuid-Amerika;  \n' +
                'French: Amérique du Sud) is a continent situated in the  \n' +
                'Western Hemisphere, mostly in the Southern Hemisphere, with  \n' +
                'a relatively small portion in the Northern Hemisphere.  \n' +
                'The continent is also considered a subcontinent of the  \n' +
                'Americas.[2][3] It is bordered on the west by the Pacific  \n' +
                'Ocean and on the north and east by the Atlantic Ocean;  \n' +
                'North America and the Caribbean Sea lie to the northwest.  \n' +
                'It includes twelve countries: Argentina, Bolivia, Brazil,  \n' +
                'Chile, Colombia, Ecuador, Guyana, Paraguay, Peru, Suriname,  \n' +
                'Uruguay, and Venezuela. The South American nations that  \n' +
                'border the Caribbean Sea—including Colombia, Venezuela,  \n' +
                'Guyana, Suriname, as well as French Guiana, which is an  \n' +
                'overseas region of France—are also known as Caribbean South  \n' +
                'America. South America has an area of 17,840,000 square  \n' +
                'kilometers (6,890,000 sq mi). Its population as of 2005  \n' +
                'has been estimated at more than 371,090,000. South America  \n' +
                'ranks fourth in area (after Asia, Africa, and North America)  \n' +
                'and fifth in population (after Asia, Africa, Europe, and  \n' +
                'North America). The word America was coined in 1507 by  \n' +
                'cartographers Martin Waldseemüller and Matthias Ringmann,  \n' +
                'after Amerigo Vespucci, who was the first European to  \n' +
                'suggest that the lands newly discovered by Europeans were  \n' +
                'not India, but a New World unknown to Europeans.'
  }
  diff: jsondiffpatch.create {
    objectHash: (obj) ->
      # try to find an id property, otherwise serialize it all
      console.info "!!!", obj
      return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);
  }
  textDB: {}
  getText: (text_id)->
    console.info 'getText', text_id
    dfd = @q.defer();
    dfd.resolve( @textDB[text_id] )
    dfd.promise;
  #Сохранение текста в базу
  setText: (text_id, new_text)->
    mythis = @;
    @getText(text_id).then (text_element)->
      old_text = text_element?.text;
      patch = mythis.diff.diff({ txt: old_text}, {txt: new_text} );
      mythis.textDB[text_id].diff = patch if old_text.length;
      mythis.textDB[text_id].length = (JSON.stringify patch).length if patch;
      console.info 'DIFF SAVED = ', text_element;
      console.info "RESTORE", mythis.diff.patch({ txt: old_text}, patch);
      patch_reverse = mythis.diff.reverse(patch)
      console.info "RESTORE-REVERS", mythis.diff.patch({ txt: new_text}, patch_reverse);


  sha: (txt)->
    CryptoJS.SHA3(txt, { outputLength: 256 }).toString()

angular.module("4treeApp").service 'textDB', TextDB
