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

  def get_last_lesson(save_parameter)
    last_lesson = get_db.execute <<-SQL
    Select #{save_parameter}_save From users
    Where login == #{get_user[0]} AND password_hash == #{get_user[1]}
    SQL
    last_lesson[0][0]
  end

  def get_elements_for_lesson(type_of_elements, lesson_num)
    unless %w[word hiragana katakana kanji].include?(type_of_elements)
      raise "element type error! should be word/hiragana/katakana/kanji"
    end
    start_id = COUNT_OF_LEARNING * lesson_num + 1
    end_id = start_id + COUNT_OF_LEARNING - 1
    elements = get_db.execute <<-SQL
      Select * From #{type_of_elements}
        Where id >= #{start_id} AND id <= #{end_id}
    SQL
    elements
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

  public :new_window, :load_main_page, :add_widgets_to_list, :get_db, :get_user, :get_last_lesson, :get_elements_for_lesson
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
  def initialize(root, main, working_type)
    @root = root
    main.new_window
    @word_button = TkButton.new(@root) do
      text "Слова"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { LessonSelectionMenu.new(root, main, working_type, "Word") })
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @hiragana_button = TkButton.new(@root) do
      text "Хирагана"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { LessonSelectionMenu.new(root, main, working_type, "Hiragana") })
      place("relx" => 0.1, "rely" => 0.3, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @katakana_button = TkButton.new(@root) do
      text "Катакана"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { LessonSelectionMenu.new(root, main, working_type, "Katakana") })
      place("relx" => 0.1, "rely" => 0.5, "relwidth" => 0.8, "relheight" => 0.15)
    end
    @kanji_button = TkButton.new(@root) do
      text "Кандзи"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { LessonSelectionMenu.new(root, main, working_type, "Kanji") })
      place("relx" => 0.1, "rely" => 0.7, "relwidth" => 0.8, "relheight" => 0.15)
    end
    main.add_widgets_to_list([@word_button, @hiragana_button, @kanji_button, @katakana_button])
  end
end

class LessonSelectionMenu
  def initialize(root, main, working_type, element_type)
    # working_type can be 1) "Learn" 2) "Test"
    unless %w[Learn Test].include?(working_type)
      raise "Check working_type!!, not #{element_type}"
    end
    # element_type can be 1) "Word" 2) "Kanji" 3) "Hiragana" 4) "Katakana"
    unless %w[Word Hiragana Katakana Kanji].include?(element_type)
      raise("Check element_type!!, not #{element_type}")
    end
    @root = root
    main.new_window
    elements = main.get_db.execute <<-SQL
    Select * From #{element_type.downcase}
    SQL
    last_lesson = main.get_last_lesson(element_type.downcase)
    num_of_lessons = (elements.length / COUNT_OF_LEARNING).ceil
    list = TkListbox.new(@root) do
      place("relx" => 0.1, "rely" => 0.1, "relwidth" => 0.6, "relheight" => 0.7)
    end
    (1..num_of_lessons).to_a.each do |lesson|
      if lesson <= last_lesson
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
        if list.curselection[0] + 1 <= last_lesson or not list.curselection[0]
          Kernel.const_get(working_type + element_type + "Element").new(@root, main, (
          if list.curselection[0]
            list.curselection[0]
          else
            0
          end
          ), 1, 1, 0)
        end
      })
      place("relx" => 0.1, "rely" => 0.85, "relwidth" => 0.8, "relheight" => 0.1)
    end
    main.add_widgets_to_list([list, @menu_button, @scroll, @confirm_button])
  end
end

class LearnKanaElement
  def initialize(root, main, lesson, index, type_of_kana, *args)
    @root = root
    main.new_window
    kana = main.get_elements_for_lesson(type_of_kana, lesson)
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

class LearnHiraganaElement < LearnKanaElement
  def initialize(root, main, lesson, index, *args)
    super root, main, lesson, index, HIRAGANA
  end
end

class LearnKatakanaElement < LearnKanaElement
  def initialize(root, main, lesson, index, *args)
    super root, main, lesson, index, KATAKANA
  end
end

class LearnKanjiElement
  def initialize(root, main, lesson, index, *args)
    @root = root
    main.new_window
    kanji = main.get_elements_for_lesson("kanji", lesson)
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
    widgets = [@writing_text, @onyomi_reading_text, @kunyomi_reading_text, @meaning_text, @examples_text, @menu_button]
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
  def initialize(root, main, lesson, index, *args)
    @root = root
    main.new_window
    words = main.get_elements_for_lesson("word", lesson)
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

def get_random_element_with_cur(array, current_element)
  result = []
  while result.length < 3
    random_element = array.sample
    if random_element != current_element and not result.include?(random_element)
      result.push(random_element)
    end
  end
  result.push(current_element)
  result.shuffle!
end

def check_answer(link_on_test, button, level, correct_answer)
  unless link_on_test.is_checked(level)
    button.background = "blue"
  end
  link_on_test.set_as_checked(level)
  if button.text != correct_answer
    link_on_test.add_errors
  end
end

class TestElementBase
  def get_phase
    @phase
  end

  def get_errors
    @errors
  end

  def add_errors
    @current_errors += 1
    update_errors
  end

  def set_as_checked(level)
    @checked[level - 1] = true
  end

  def is_checked(level)
    @checked[level - 1]
  end

  def is_error
    if @current_errors == 0
      0
    else
      1
    end
  end

  def update_errors
    errors = @errors
    if @current_errors
      errors += 1
    end
    if @index + 1 <= 15
      status = "Фаза: #{@phase}/2 | Прогресс: #{@index + 1}/#{COUNT_OF_LEARNING} | Ошибок: #{errors}/#{COUNT_OF_LEARNING * 2}"
    elsif @index + 1 > 15 and @phase == 1
      status = "Фаза: 2/2 | Прогресс: 1/#{COUNT_OF_LEARNING} | Ошибок: #{errors}/#{COUNT_OF_LEARNING * 2}"
    else  # phase == 2 and next index == 16
      status = "Фаза: 2/2 | Прогресс: #{COUNT_OF_LEARNING}/#{COUNT_OF_LEARNING} | Ошибок: #{errors}/#{COUNT_OF_LEARNING * 2}"
    end
    @status_label.text = status
  end

  public :set_as_checked, :add_errors, :get_errors, :get_phase, :is_error, :is_checked
end

class TestWordElement < TestElementBase
  def initialize(root, main, lesson, index, phase, errors)
    @errors = errors
    @phase = phase
    @index = index
    @current_errors = 0
    @checked = [false, false]
    @root = root
    main.new_window
    words = main.get_elements_for_lesson("word", lesson)
    current_word = words[index - 1]
    link_on_this = self
    status = "Фаза: #{@phase}/2 | Прогресс: #{index}/#{COUNT_OF_LEARNING} | Ошибок: #{errors}/#{COUNT_OF_LEARNING * 2}"
    @status_label = TkLabel.new(@root) do
      font TkFont.new('times 16 bold')
      text status
      place("relx" => 0.05, "rely" => 0.05, "relwidth" => 0.9, "relheight" => 0.1)
    end
    @question_label = TkLabel.new(@root) do
      font TkFont.new('times 16 bold')
      if link_on_this.get_phase == 1
        text "Написание: " + current_word[1]
      else
        text "Значение: " + current_word[3]
      end
      place("relx" => 0.05, "rely" => 0.2, "relwidth" => 0.9, "relheight" => 0.1)
    end

    readings_all_words = []
    words.each { |word| readings_all_words.push(word[2]) }
    reading = get_random_element_with_cur(readings_all_words, current_word[2])
    first_level_buttons = []
    x = 0.0
    (0..3).each do |index|
      button = TkButton.new(@root) do
        text reading[index]
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { check_answer(link_on_this, self, 1, current_word[2]) })
        place("relx" => x, "rely" => 0.4, "relwidth" => 0.25, "relheight" => 0.15)
      end
      x += 0.25
      first_level_buttons.push(button)
    end
    second_level_buttons = []
    x = 0.0
    if @phase == 1
      meanings_all_words = []
      words.each { |word| meanings_all_words.push(word[3]) }
      elements = get_random_element_with_cur(meanings_all_words, current_word[3])
      correct_element = current_word[3]
    else
      writing_all_words = []
      words.each { |word| writing_all_words.push(word[1]) }
      elements = get_random_element_with_cur(writing_all_words, current_word[1])
      correct_element = current_word[1]
    end
    (0..3).each do |index|
      button = TkButton.new(@root) do
        text elements[index]
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { check_answer(link_on_this, self, 2, correct_element) })
        place("relx" => x, "rely" => 0.6, "relwidth" => 0.25, "relheight" => 0.15)
      end
      x += 0.25
      second_level_buttons.push(button)
    end
    @confirm_button = TkButton.new(@root) do
      text "Далее"
      font TkFont.new('times 16 bold')
      activebackground "blue"
      command(proc {
        if link_on_this.is_checked(1) and link_on_this.is_checked(2)
          if index < 15
            TestWordElement.new(root, main, lesson, index + 1, link_on_this.get_phase, link_on_this.get_errors + link_on_this.is_error)
          elsif link_on_this.get_phase == 1 and index == 15
            TestWordElement.new(root, main, lesson, 1, 2, link_on_this.get_errors + link_on_this.is_error)
          elsif link_on_this.get_phase == 2 and index == 15
            AfterTestMenuWord.new(root, main, errors, lesson)
          end
        end
      })
      place("relx" => 0.1, "rely" => 0.8, "relwidth" => 0.8, "relheight" => 0.15)
    end
    widgets = [@status_label, @question_label]
    widgets += first_level_buttons
    widgets += second_level_buttons
    main.add_widgets_to_list(widgets)
  end
end

class TestKanaElement
  def initialize(root, main, lesson, index, phase, errors, type_of_kana)
    @phase = phase
    @errors = errors
    @current_errors = 0
    @checked = [false, false]
    @index = index
    main.new_window
    kana = main.get_elements_for_lesson(type_of_kana, lesson)
    current_element = kana[index - 1]
    link_on_this = self
    status = "Фаза: #{phase}/2 | Прогресс: #{index}/#{COUNT_OF_LEARNING} | Ошибок: #{errors}/#{COUNT_OF_LEARNING * 2}"
    @status_label = TkLabel.new(root) do
      font TkFont.new('times 16 bold')
      text status
      place("relx" => 0.05, "rely" => 0.05, "relwidth" => 0.9, "relheight" => 0.1)
    end
    @question_label = TkLabel.new(root) do
      font TkFont.new('times 16 bold')
      if link_on_this.get_phase == 1
        text "Написание: " + current_element[1]
      else
        text "Чтение: " + current_element[2]
      end
      place("relx" => 0.05, "rely" => 0.2, "relwidth" => 0.9, "relheight" => 0.1)
    end
    first_level_buttons = []
    x = 0.0
    if phase == 1
      readings_all_kana = []
      kana.each { |element| readings_all_kana.push(element[2]) }
      elements = get_random_element_with_cur(readings_all_kana, current_element[2])
      correct_element = current_element[2]
    else
      writing_all_kana = []
      kana.each { |element| writing_all_kana.push(element[1]) }
      elements = get_random_element_with_cur(writing_all_kana, current_element[1])
      correct_element = current_element[1]
    end
    (0..3).each do |index|
      button = TkButton.new(root) do
        text elements[index]
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { check_answer(link_on_this, self, 1, correct_element) })
        place("relx" => x, "rely" => 0.6, "relwidth" => 0.25, "relheight" => 0.15)
      end
      x += 0.25
      first_level_buttons.push(button)
    end
    @confirm_button = TkButton.new(root) do
      text "Далее"
      font TkFont.new('times 16 bold')
      activebackground "blue"
      command(proc {
        if link_on_this.is_checked(1) and link_on_this.is_checked(2)
          if index < 15
            TestKanaElement.new(root, main, lesson, index + 1, link_on_this.get_phase, link_on_this.get_errors + link_on_this.is_error, type_of_kana)
          elsif link_on_this.get_phase == 1 and index == 15
            TestKanaElement.new(root, main, lesson, 1, 2, link_on_this.get_errors + link_on_this.is_error, type_of_kana)
          elsif link_on_this.get_phase == 2 and index == 15
            AfterTestMenuKana.new(root, main, errors, lesson, type_of_kana)
          end
        end
      })
      place("relx" => 0.1, "rely" => 0.8, "relwidth" => 0.8, "relheight" => 0.15)
    end
    widgets = [@status_label, @question_label]
    widgets += first_level_buttons
    main.add_widgets_to_list(widgets)
  end
end

class TestHiraganaElement < TestKanaElement
  def initialize(root, main, lesson, index, phase, errors)
    super root, main, lesson, index, phase, errors, HIRAGANA
  end
end

class TestKatakanaElement < TestKanaElement
  def initialize(root, main, lesson, index, phase, errors)
    super root, main, lesson, index, phase, errors, KATAKANA
  end
end

class TestKanjiElement < TestElementBase
  def initialize(root, main, lesson, index, phase, errors)
    @phase = phase
    @errors = errors
    @current_errors = 0
    @checked = [false, false, false]
    @index = index

    main.new_window
    kanji = main.get_elements_for_lesson("kanji", lesson)
    current_kanji = kanji[index - 1]
    link_on_this = self
    status = "Фаза: #{@phase}/2 | Прогресс: #{index}/#{COUNT_OF_LEARNING} | Ошибок: #{errors}/#{COUNT_OF_LEARNING * 2}"
    @status_label = TkLabel.new(root) do
      font TkFont.new('times 16 bold')
      text status
      place("relx" => 0.05, "rely" => 0.05, "relwidth" => 0.9, "relheight" => 0.1)
    end
    @question_label = TkLabel.new(root) do
      font TkFont.new('times 26 bold')
      if link_on_this.get_phase == 1
        text "Написание: " + current_kanji[1]
      else
        text "Значение: " + current_kanji[4]
      end
      place("relx" => 0.05, "rely" => 0.2, "relwidth" => 0.9, "relheight" => 0.1)
    end
    #need testing this in bugs
    onyomi_readings_for_all_kanji = []
    kanji.each { |element| onyomi_readings_for_all_kanji.push(element[2]) }
    onyomi_reading = get_random_element_with_cur(onyomi_readings_for_all_kanji, current_kanji[2])
    first_level_buttons = []
    x = 0.0
    (0..3).each do |index|
      button = TkButton.new(root) do
        text onyomi_reading[index]
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { check_answer(link_on_this, self, 1, current_kanji[2]) })
        place("relx" => x, "rely" => 0.35, "relwidth" => 0.25, "relheight" => 0.1)
      end
      x += 0.25
      first_level_buttons.push(button)
    end

    kunyomi_readings_for_all_kanji = []
    kanji.each { |element| kunyomi_readings_for_all_kanji.push(element[3]) }
    kunyomi_reading = get_random_element_with_cur(kunyomi_readings_for_all_kanji, current_kanji[3])
    second_level_buttons = []
    x = 0.0
    (0..3).each do |index|
      button = TkButton.new(root) do
        text kunyomi_reading[index]
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { check_answer(link_on_this, self, 2, current_kanji[3]) })
        place("relx" => x, "rely" => 0.5, "relwidth" => 0.25, "relheight" => 0.1)
      end
      x += 0.25
      second_level_buttons.push(button)
    end
    if @phase == 1
      meanings_all_kanji = []
      kanji.each { |element| meanings_all_kanji.push(element[4]) }
      elements = get_random_element_with_cur(meanings_all_kanji, current_kanji[4])
      correct_element = current_kanji[4]
    else
      writing_all_kanji = []
      kanji.each { |element| writing_all_kanji.push(element[1]) }
      elements = get_random_element_with_cur(writing_all_kanji, current_kanji[1])
      correct_element = current_kanji[1]
    end
    third_level_buttons = []
    x = 0.0
    (0..3).each do |index|
      button = TkButton.new(root) do
        text elements[index]
        font TkFont.new('times 16 bold')
        activebackground "blue"
        command(proc { check_answer(link_on_this, self, 3, correct_element) })
        place("relx" => x, "rely" => 0.65, "relwidth" => 0.25, "relheight" => 0.1)
      end
      x += 0.25
      third_level_buttons.push(button)
    end
    # end of testing
    @confirm_button = TkButton.new(root) do
      text "Далее"
      font TkFont.new('times 16 bold')
      activebackground "blue"
      command(proc {
        if link_on_this.is_checked(1) and link_on_this.is_checked(2) and link_on_this.is_checked(3)
          if index < 15
            TestKanjiElement.new(root, main, lesson, index + 1, link_on_this.get_phase, link_on_this.get_errors + link_on_this.is_error)
          elsif link_on_this.get_phase == 1 and index == 15
            TestKanjiElement.new(root, main, lesson, 1, 2, link_on_this.get_errors + link_on_this.is_error)
          elsif link_on_this.get_phase == 2 and index == 15
            AfterTestMenuKanji.new(root, main, errors, lesson)
          end
        end
      })
      place("relx" => 0.1, "rely" => 0.8, "relwidth" => 0.8, "relheight" => 0.15)
    end
    widgets = [@status_label, @question_label, @confirm_button]
    widgets += first_level_buttons
    widgets += second_level_buttons
    widgets += third_level_buttons
    main.add_widgets_to_list(widgets)
  end
end

class AfterTestMenu
  def initialize(root, main, errors, current_lesson, type_of_element)
    main.new_window
    status = "Фаза: 2/2 | "
    status += "Прогресс #{COUNT_OF_LEARNING}/#{COUNT_OF_LEARNING}\n"
    status += "Ошибок: #{errors}/#{COUNT_OF_LEARNING * 2}\n"
    if errors < COUNT_OF_LEARNING * 2 * 0.1
      result = true
    else
      result = false
    end
    if result
      last_lesson = main.get_last_lesson(type_of_element.downcase)
      if last_lesson == current_lesson
        main.get_db.execute <<-SQL
        UPDATE users
        SET #{type_of_element.downcase}_save = #{last_lesson + 1}
          Where login == #{main.get_user[0]} AND password_hash == #{main.get_user[1]}
        SQL
      end
    end
    status += "Тест: #{
    if result
      'пройден.'
    else
      'не пройден.'
    end}"
    @status_label = TkLabel.new(root) do
      font TkFont.new("times 16 bold")
      text status
      place("relx" => 0.05, "rely" => 0.4, "relwidth" => 0.9, "relheight" => 0.2)
    end
    @menu_button = TkButton.new(root) do
      text "Меню"
      font TkFont.new('times 20 bold')
      activebackground "blue"
      command(proc { main.load_main_page })
      place("relx" => 0.8, "rely" => 0.1, "relwidth" => 0.1, "relheight" => 0.1)
    end
    main.add_widgets_to_list([@status_label, @menu_button])
  end
end

class AfterTestMenuWord < AfterTestMenu
  def initialize(root, main, errors, lesson)
    super root, main, errors, lesson, "word"
  end
end

class AfterTestMenuKana < AfterTestMenu
  def initialize(root, main, errors, lesson, type_of_kana)
    super root, main, errors, lesson, type_of_kana
  end
end

class AfterTestMenuKanji < AfterTestMenu
  def initialize(root, main, errors, lesson)
    super root, main, errors, lesson, "kanji"
  end
end

db = SQLite3::Database.new("C:\\Users\\User\\RubymineProjects\\untitled\\Nihongo_programm\\Main.sqlite")
app = Main.new(db)