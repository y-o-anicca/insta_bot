require 'selenium-webdriver'
require './secrets.rb'
require 'byebug'
include Secrets

class InstaBot
  attr_accessor :driver, :user_name

  def initialize(user_name, pass)
    @driver = Selenium::WebDriver.for :chrome
    @user_name = user_name
    login(user_name, pass)
  end


  def login(user_name, pass)
    driver.get('https://www.instagram.com')
    sleep(2)
    # ログインボタン押下
    login_btn = driver.find_element(:xpath, "//a[contains(text(), 'ログインする')]")
    login_btn.click
    sleep(2)
    # ユーザネームとパスワード入力
    name_in = driver.find_element(:xpath, "//input[contains(@name, 'username')]")
    name_in.send_keys(user_name)

    pass_in = driver.find_element(:xpath, "//input[contains(@name, 'password')]")
    pass_in.send_keys(pass)

    sub_btn = driver.find_element(:xpath, "//button[contains(@type, 'submit')]")
    sub_btn.click
    sleep(2)

    poppup_btn = driver.find_element(:xpath, "//button[contains(text(), '後で')]")
    poppup_btn.click
  end

  def get_unfollowers
    # プロフィールページに遷移
    driver.find_element(:xpath, "//a[contains(@href, '/#{user_name}/')]").click
    sleep(1)
    # フォロー中ボタン押下
    driver.find_element(:xpath, "//a[contains(@href, '#{user_name}/following/')]").click
    sleep(1)
    followings = get_names
    # フォロー中ボタン押下
    driver.find_element(:xpath, "//a[contains(@href, '#{user_name}/followers/')]").click
    sleep(1)
    followers = get_names

    unfollowers = followings.map {|following| following unless followers.include?(following)}.compact
  end

  # Lazyloadのため、初回ロード時に全ての要素が含まれていないため、
  # ページ下部へのスクロール処理が終了してから、要素全体を返却
  def get_names
    # スクロール対象
    scroll_box = driver.find_element(:xpath, "/html/body/div[4]/div/div[2]")
    # スクロール前とスクロール後の高さが一緒になったら終了
    last_ht, ht = 0, 1
    while last_ht != ht
      last_ht = ht
      sleep(1)
      ht = driver.execute_script("arguments[0].scrollTo(0, arguments[0].scrollHeight);return arguments[0].scrollHeight;", scroll_box)
    end
    # フォロー中の人物リンクを全て得
    links = scroll_box.find_elements(:tag_name, 'a')
    names = links.map {|link| link.text unless link.text == ''}.compact

    # スクロール対象閉じる
    driver.find_element(:xpath, "/html/body/div[4]/div/div[1]/div/div[2]/button").click

    names
  end


end
