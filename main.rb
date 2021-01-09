require 'tk'
require 'sqlite3'

COUNT_OF_LEARNING = 15
HIRAGANA = "hiragana"
KATAKANA = "katakana"

class Main
  def initialize(db)
    @db = db
    @user = [1, 1]
    @root = TkRoot.new do
      title "Nihongo"
    end
    @list_widgets = []
    load_main_page
    Tk.mainloop
  end

  def get_db
    @db
  end

  def get_user
    @user
  end

  def new_window
    unless @list_widgets.is_a?(NilClass)
      @list_widgets.each do |widget|
        widget.destroy
      end
      @list_widgets = []
    end
  end

  def add_widgets_to_list(widgets)
    @list_widgets += widgets
  end

  def load_main_page
    new_window
    main_instance = self
    @learning_button = TkButton.new(@root) do
      text "Обучение"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { SelectionMenu.new(@root, main_instance, "Learn") })
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @testing_button = TkButton.new(@root) do
      text "Тестирование"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { SelectionMenu.new(@root, main_instance, "Test") })
      place("relx" => 0.1, "rely" => 0.3, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @setup_button = TkButton.new(@root) do
      text "Настройки"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc {})
      place("relx" => 0.1, "rely" => 0.5, "relwidth" => 0.8, "relheight" => 0.15)
    end

    @support_button = TkButton.new(@root) do
      text "Справка"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { Support.new(@root, main_instance) })
      place("relx" => 0.1, "rely" => 0.7, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @list_widgets = [@learning_button, @testing_button, @setup_button, @support_button]
  end

  public :new_window, :load_main_page, :add_widgets_to_list, :get_db, :get_user
end


class Support
  def initialize(root, main)
    @root = root
    main.new_window
    @support_text = TkText.new(@root) do
      font TkFont.new('times 14 bold')
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.8, "relheight" => 0.8)
    end
    text = <<TEXT
1) Данная программа позволяет выучить две азбуки японского алфавита,
слова и кандзи.
Но программа не содержит уроков по грамматике японского языка

2) Сначала рекомендуется изучить азбуки(катакана и хирагана),
а уже потом слова и кандзи

3) Новые слова и кандзи, которых нет в программе, вы можете
добавить в настройках в главном меню.

4) Если слово или кандзи есть в программе, но не имеет звука или
изображения, вы можете добавить их,
если введёте написание, чтение и значения такими,
какими они написаны в программе

5) В конце каждого урока вам будет предложено пройти тест,
чтобы перейти к следующему уроку.
Чтобы пройти тест вам необходимо допустить менее 1 % ошибок.
В тесте из 15 вопросов, следовательно, 0 ошибок.
В тесте из 700 вопрос — не более 7 ошибок.

6)　Вы можете пройти тест по всем изученным словам или
иероглифам в пункте "Проверка" главного меню.
Также вы можете повторить любой из изученных уроков и / или
пройти по нему тест заново.
Если вы провалите уже пройденный тест, ваш прогресс утерян не будет.

7) Вы всегда можете сбросить свои сохранения для каждого
раздела отдельно, нажав на кнопку "Начать сначала".
TEXT
    @support_text.insert("end", text)
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    main.add_widgets_to_list([@support_text, @menu_button])
  end
end

class SelectionMenu
  def initialize(root, main, prefix_class_of_selection)
    @root = root
    main.new_window
    @word_button = TkButton.new(@root) do
      text "Слова"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { Kernel.const_get(prefix_class_of_selection + "Words").new(root, main) })
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @hiragana_button = TkButton.new(@root) do
      text "Хирагана"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { Kernel.const_get(prefix_class_of_selection + "Kana").new(root, main, HIRAGANA) })
      place("relx" => 0.1, "rely" => 0.3, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @katakana_button = TkButton.new(@root) do
      text "Катакана"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { Kernel.const_get(prefix_class_of_selection + "Kana").new(root, main, KATAKANA) })
      place("relx" => 0.1, "rely" => 0.5, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @kanji_button = TkButton.new(@root) do
      text "Кандзи"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { Kernel.const_get(prefix_class_of_selection + "Kanji").new(root, main) })
      place("relx" => 0.1, "rely" => 0.7, "relwidth" => 0.8, "relheight" => 0.15)
    end
    main.add_widgets_to_list([@word_button, @hiragana_button, @kanji_button, @katakana_button])
  end
end

class LearnKana
  def initialize(root, main, type_of_kana)
    @root = root
    main.new_window
    kana_table = (
    if type_of_kana == HIRAGANA then
      "hiragana"
    else
      "katakana"
    end)
    kana = main.get_db.execute <<-SQL
    Select * From #{kana_table}
    SQL
    last_lesson = main.get_db.execute <<-SQL
    Select #{type_of_kana}_save From users
    Where login == #{main.get_user[0]} AND password_hash == #{main.get_user[1]}
    SQL
    num_of_lessons = (kana.length / COUNT_OF_LEARNING).ceil
    list = TkListbox.new(@root) do
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.6, "relheight" => 0.7)
    end
    (1..num_of_lessons).to_a.each do |lesson|
      if lesson <= last_lesson[0][0]
        list.insert(lesson - 1, lesson)
      else
        list.insert(lesson - 1, lesson.to_s + " |Ещё не открыт!|")
      end
    end
    @scroll = TkScrollbar.new(@root) do
      orient 'vertical'
      place("relx" => 0.7, "rely" => 0.1, "relwidth" => 0.015, "relheight" => 0.7)
    end
    list.yscrollcommand(proc { |*args|
      @scroll.set(*args)
    })
    @scroll.command(proc { |*args|
      list.yview(*args)
    })
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    @confirm_button = TkButton.new(@root) do
      text "Выбрать"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc {
        LearnKanaElement.new(@root, main, (
        if list.curselection[0] then
          list.curselection[0]
        else
          0
        end
        ), 1, type_of_kana)
      })
      place("relx" => 0.1, "rely" => 0.85, "relwidth" => 0.8, "relheight" => 0.1)
    end
    main.add_widgets_to_list([list, @menu_button, @scroll, @confirm_button])
  end
end

class LearnKanji
  def initialize(root, main)
    @root = root
    main.new_window
    kanji = main.get_db.execute <<-SQL
    Select * From kanji
    SQL
    last_lesson = main.get_db.execute <<-SQL
    Select kanji_save From users
    Where login == #{main.get_user[0]} AND password_hash == #{main.get_user[1]}
    SQL
    num_of_lessons = (kanji.length / COUNT_OF_LEARNING).ceil
    list = TkListbox.new(@root) do
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.6, "relheight" => 0.7)
    end
    (1..num_of_lessons).to_a.each do |lesson|
      if lesson <= last_lesson[0][0]
        list.insert(lesson - 1, lesson)
      else
        list.insert(lesson - 1, lesson.to_s + " |Ещё не открыт!|")
      end
    end
    @scroll = TkScrollbar.new(@root) do
      orient 'vertical'
      place("relx" => 0.7, "rely" => 0.1, "relwidth" => 0.015, "relheight" => 0.7)
    end
    list.yscrollcommand(proc { |*args|
      @scroll.set(*args)
    })
    @scroll.command(proc { |*args|
      list.yview(*args)
    })
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    @confirm_button = TkButton.new(@root) do
      text "Выбрать"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc {
        LearnKanjiElement.new(@root, main, (
        if list.curselection[0] then
          list.curselection[0]
        else
          0
        end
        ), 1)
      })
      place("relx" => 0.1, "rely" => 0.85, "relwidth" => 0.8, "relheight" => 0.1)
    end
    main.add_widgets_to_list([list, @menu_button, @scroll, @confirm_button])
  end
end

class LearnWords
  def initialize(root, main)
    @root = root
    main.new_window
    words = main.get_db.execute <<-SQL
    Select * From word
    SQL
    last_lesson = main.get_db.execute <<-SQL
    Select words_save From users
    Where login == #{main.get_user[0]} AND password_hash == #{main.get_user[1]}
    SQL
    num_of_lessons = (words.length / COUNT_OF_LEARNING).ceil
    list = TkListbox.new(@root) do
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.6, "relheight" => 0.7)
    end
    (1..num_of_lessons).to_a.each do |lesson|
      if lesson <= last_lesson[0][0]
        list.insert(lesson - 1, lesson)
      else
        list.insert(lesson - 1, lesson.to_s + " |Ещё не открыт!|")
      end
    end
    @scroll = TkScrollbar.new(@root) do
      orient 'vertical'
      place("relx" => 0.7, "rely" => 0.1, "relwidth" => 0.015, "relheight" => 0.7)
    end
    list.yscrollcommand(proc { |*args|
      @scroll.set(*args)
    })
    @scroll.command(proc { |*args|
      list.yview(*args)
    })
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    @confirm_button = TkButton.new(@root) do
      text "Выбрать"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc {
        LearnWordElement.new(@root, main, (
        if list.curselection[0] then
          list.curselection[0]
        else
          0
        end
        ), 1)
      })
      place("relx" => 0.1, "rely" => 0.85, "relwidth" => 0.8, "relheight" => 0.1)
    end
    main.add_widgets_to_list([list, @menu_button, @scroll, @confirm_button])
  end
end

class LearnKanaElement
  def initialize(root, main, lesson, index, type_of_kana)
    @root = root
    main.new_window
    start_id = COUNT_OF_LEARNING * lesson + 1
    end_id = start_id + COUNT_OF_LEARNING - 1
    kana_table = (
    if type_of_kana == HIRAGANA then
      "hiragana"
    else
      "katakana"
    end)
    kana = main.get_db.execute <<-SQL
      Select * From #{kana_table}
        Where id >= #{start_id} AND id <= #{end_id}
    SQL
    current_word = kana[index - 1]
    @writing_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.1, "relwidth" => 0.6, "relheight" => 0.25)
    end
    @writing_text.insert("end", "Написание:  " + current_word[1])
    @reading_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.4, "relwidth" => 0.6, "relheight" => 0.25)
    end
    @reading_text.insert("end", "Чтение:  " + current_word[2])
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    widgets = [@writing_text, @reading_text, @menu_button]
    if index < 15
      @right_button = TkButton.new(@root) do
        text "Следующий слог"
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { LearnKanaElement.new(@root, main, lesson, index + 1, type_of_kana) })
        place("relx" => 0.8, "rely" => 0.45, "relwidth" => 0.15, "relheight" => 0.1)
      end
      widgets.push(@right_button)
    end
    if index > 1
      @left_button = TkButton.new(@root) do
        text "Предыдущий слог"
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { LearnWordElement.new(@root, main, lesson, index - 1) })
        place("relx" => 0.05, "rely" => 0.45, "relwidth" => 0.15, "relheight" => 0.1)
      end
      widgets.push(@left_button)
    end
    main.add_widgets_to_list(widgets)
  end
end

class LearnKanjiElement
  def initialize(root, main, lesson, index)
    @root = root
    main.new_window
    start_id = COUNT_OF_LEARNING * lesson + 1
    end_id = start_id + COUNT_OF_LEARNING - 1
    kanji = main.get_db.execute <<-SQL
      Select * From kanji
        Where id >= #{start_id} AND id <= #{end_id}
    SQL
    current_word = kanji[index - 1]
    @writing_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.025, "relwidth" => 0.6, "relheight" => 0.15)
    end
    @writing_text.insert("end", "Написание:  " + current_word[1])
    @onyomi_reading_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.225, "relwidth" => 0.6, "relheight" => 0.15)
    end
    @onyomi_reading_text.insert("end", "Онное чтение:  " + current_word[2])
    @kunyomi_reading_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.425, "relwidth" => 0.6, "relheight" => 0.15)
    end
    @kunyomi_reading_text.insert("end", "Кунное чтение:  " + current_word[3])
    @meaning_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.625, "relwidth" => 0.6, "relheight" => 0.15)
    end
    @meaning_text.insert("end", "Значение:  " + current_word[4])
    @examples_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.825, "relwidth" => 0.6, "relheight" => 0.15)
    end
    unless current_word[5].is_a?(NilClass)
      @examples_text.insert("end", "Примеры:  " + current_word[5])
    end
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    widgets = [@writing_text, @onyomi_reading_text, @kunyomi_reading_text, @meaning_text, @menu_button]
    unless current_word[7].is_a?(NilClass)
      @image_kanji = TkPhotoImage.new
      @image_kanji.file = ".//" + current_word[7]
      @image_label = TkLabel.new(@root)
      @image_label.image = @image_kanji
      @image_label.place("relx" => 0.8, "rely" => 0.6, "relwidth" => 0.2, "relheight" => 0.25)
    end
    widgets.push(@image_label)
    if index < 15
      @right_button = TkButton.new(@root) do
        text "Следующий кандзи"
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { LearnKanjiElement.new(@root, main, lesson, index + 1) })
        place("relx" => 0.8, "rely" => 0.45, "relwidth" => 0.15, "relheight" => 0.1)
      end
      widgets.push(@right_button)
    end
    if index > 1
      @left_button = TkButton.new(@root) do
        text "Предыдущий кандзи"
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { LearnKanjiElement.new(@root, main, lesson, index - 1) })
        place("relx" => 0.05, "rely" => 0.45, "relwidth" => 0.15, "relheight" => 0.1)
      end
      widgets.push(@left_button)
    end
    main.add_widgets_to_list(widgets)
  end
end

class LearnWordElement
  def initialize(root, main, lesson, index)
    @root = root
    main.new_window
    start_id = COUNT_OF_LEARNING * lesson + 1
    end_id = start_id + COUNT_OF_LEARNING - 1
    words = main.get_db.execute <<-SQL
      Select * From word
        Where id >= #{start_id} AND id <= #{end_id}
    SQL
    current_word = words[index - 1]
    @writing_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.1, "relwidth" => 0.6, "relheight" => 0.25)
    end
    @writing_text.insert("end", "Написание:  " + current_word[1])
    @reading_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.4, "relwidth" => 0.6, "relheight" => 0.25)
    end
    @reading_text.insert("end", "Чтение:  " + current_word[2])
    @meaning_text = TkText.new(@root) do
      font TkFont.new("font 24 bold")
      place("relx" => 0.2, "rely" => 0.7, "relwidth" => 0.6, "relheight" => 0.25)
    end
    @meaning_text.insert("end", "Значение:  " + current_word[3])
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    widgets = [@writing_text, @reading_text, @meaning_text, @menu_button]
    if index < 15
      @right_button = TkButton.new(@root) do
        text "Следующее слово"
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { LearnWordElement.new(@root, main, lesson, index + 1) })
        place("relx" => 0.8, "rely" => 0.45, "relwidth" => 0.15, "relheight" => 0.1)
      end
      widgets.push(@right_button)
    end
    if index > 1
      @left_button = TkButton.new(@root) do
        text "Предыдущее слово"
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { LearnWordElement.new(@root, main, lesson, index - 1) })
        place("relx" => 0.05, "rely" => 0.45, "relwidth" => 0.15, "relheight" => 0.1)
      end
      widgets.push(@left_button)
    end
    main.add_widgets_to_list(widgets)
  end
end

class TestWords
  def initialize(root, main)
    @root = root
    main.new_window
    words = main.get_db.execute <<-SQL
    Select * From word
    SQL
    last_lesson = main.get_db.execute <<-SQL
    Select words_save From users
    Where login == #{main.get_user[0]} AND password_hash == #{main.get_user[1]}
    SQL
    num_of_lessons = (words.length / COUNT_OF_LEARNING).ceil
    list = TkListbox.new(@root) do
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.6, "relheight" => 0.7)
    end
    (1..num_of_lessons).to_a.each do |lesson|
      if lesson <= last_lesson[0][0]
        list.insert(lesson - 1, lesson)
      else
        list.insert(lesson - 1, lesson.to_s + " |Ещё не открыт!|")
      end
    end
    @scroll = TkScrollbar.new(@root) do
      orient 'vertical'
      place("relx" => 0.7, "rely" => 0.1, "relwidth" => 0.015, "relheight" => 0.7)
    end
    list.yscrollcommand(proc { |*args|
      @scroll.set(*args)
    })
    @scroll.command(proc { |*args|
      list.yview(*args)
    })
    @menu_button = TkButton.new(@root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    @confirm_button = TkButton.new(@root) do
      text "Выбрать"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { 
        TestWordElement.new(@root, main, (
        if list.curselection[0] then
          list.curselection[0]
        else
          0
        end
        ), 1)
      })
      place("relx" => 0.1, "rely" => 0.85, "relwidth" => 0.8, "relheight" => 0.1)
    end
    main.add_widgets_to_list([list, @menu_button, @scroll, @confirm_button])
  end
end

db = SQLite3::Database.new("C:\\Users\\User\\RubymineProjects\\untitled\\Nihongo_programm\\Main.sqlite")

app = Main.new(db)