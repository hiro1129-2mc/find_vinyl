require 'rails_helper'

RSpec.describe "アイテム", type: :system do
  include LoginMacros
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:collection_item) { create(:item, :collection, user: user) }
  let(:want_item) { create(:item, :want, user: user) }

  describe 'アイテムのCRUD' do
    describe 'アイテム一覧' do
      context 'ログインしていない場合' do
        context 'コレクション一覧' do
          it 'ログインページにリダイレクトされること' do
            visit '/collection_items'
            expect(page).to have_current_path("/login", ignore_query: true), 'ログインページへ遷移できません'
            expect(page).to have_content('ログインしてください'), 'フラッシュメッセージ「ログインしてください」が表示されていません'
          end
        end

        context '欲しいもの一覧' do
          it 'ログインページにリダイレクトされること' do
            visit '/want_items'
            expect(page).to have_current_path("/login", ignore_query: true), 'ログインページへ遷移できません'
            expect(page).to have_content('ログインしてください'), 'フラッシュメッセージ「ログインしてください」が表示されていません'
          end
        end
      end

      context 'ログインしている場合' do
        before do
          login(user)
        end
        it 'サイドバーのリンクからコレクションリストへ遷移できること' do
          find('#menuToggle').click
          click_on('コレクションリスト')
          expect(page).to have_current_path("/collection_items", ignore_query: true), 'サイドバーのリンクからコレクションリストへ遷移できません'
        end

        it 'サイドバーのリンクから欲しいものリストへ移動できること' do
          find('#menuToggle').click
          click_on('欲しいものリスト')
          expect(page).to have_current_path("/want_items", ignore_query: true), 'サイドバーのリンクから欲しいものリストへ遷移できません'
        end

        context 'アイテムが一件もない場合' do
          context 'コレクション' do
            it '何もない旨のメッセージが表示されること' do
              find('#menuToggle').click
              click_on('コレクションリスト')
              expect(page).to have_content('コレクションがありません'), 'コレクションが一件もない場合、「コレクションがありません」というメッセージが表示されていません'
            end
          end

          context '欲しいもの' do
            it '何もない旨のメッセージが表示されること' do
              find('#menuToggle').click
              click_on('欲しいものリスト')
              expect(page).to have_content('欲しいものがありません'), '欲しいものが一件もない場合、「欲しいものがありません」というメッセージが表示されていません'
            end
          end
        end

        context 'アイテムがある場合' do
          context 'コレクション' do
            it 'コレクション一覧が表示されること' do
              collection_item
              find('#menuToggle').click
              click_on('コレクションリスト')
              expect(page).to have_current_path("/collection_items", wait: 10)
              expect(page).to have_content(collection_item.title.name, wait: 10), 'コレクションリストにコレクションのタイトルが表示されていません'
              expect(page).to have_content(collection_item.artist_name.name), 'コレクションリストにコレクションのアーティスト名が表示されていません'
              collection_item.tags.each do |tag|
                expect(page).to have_content(tag.name), 'コレクションリストにコレクションのタグが表示されていません'
              end
            end

            context '10件以下の場合' do
              let!(:collection_items) { create_list(:item, 10, :collection, user: user) }
              it 'ページングが表示されないこと' do
                visit '/collection_items'
                expect(page).not_to have_selector('.pagination'), 'ページングが表示されています'
              end
            end

            context '11件以上ある場合' do
              let!(:collection_items) { create_list(:item, 11, :collection, user: user) }
              it 'ページネーションが表示されること' do
                visit '/collection_items'
                expect(page).to have_selector('.pagination'), 'ページングが表示されていません'
              end
            end
          end

          context '欲しいもの' do
            it '欲しいもの一覧が表示されること' do
              want_item
              find('#menuToggle').click
              click_on('欲しいものリスト')
              expect(page).to have_current_path("/want_items", wait: 10)
              expect(page).to have_content(want_item.title.name, wait: 10), '欲しいものリストに欲しいもののタイトルが表示されていません'
              expect(page).to have_content(want_item.artist_name.name), '欲しいものリストに欲しいもののアーティスト名が表示されていません'
              want_item.tags.each do |tag|
                expect(page).to have_content(tag.name), '欲しいものリストに欲しいもののタグが表示されていません'
              end
            end

            context '10件以下の場合' do
              let!(:want_items) { create_list(:item, 10, :want, user: user) }
              it 'ページングが表示されないこと' do
                visit '/want_items'
                expect(page).not_to have_selector('.pagination'), 'ページングが表示されています'
              end
            end

            context '11件以上ある場合' do
              let!(:want_items) { create_list(:item, 11, :want, user: user) }
              it 'ページネーションが表示されること' do
                visit '/want_items'
                expect(page).to have_selector('.pagination'), 'ページングが表示されていません'
              end
            end
          end
        end
      end
    end

    describe 'アイテムの詳細' do
      context 'ログインしていない場合' do
        let!(:item) { create(:item, :collection, user: user) }
        it 'ログインページにリダイレクトされること' do
          visit item_path(item)
          expect(page).to have_current_path("/login", ignore_query: true), 'ログインページへ遷移できません'
          expect(page).to have_content('ログインしてください'), 'フラッシュメッセージ「ログインしてください」が表示されていません'
        end
      end

      context 'ログインしている場合' do
        before do
          login(user)
        end
        let!(:item) { create(:item, :collection, user: user) }
        context '自分のアイテム' do
          it 'アイテムの詳細が表示されること' do
            visit '/collection_items'
            expect(page).to have_link(item.title.name, wait: 10)
            click_link(item.title.name, exact: true)
            expect(page).to have_content("コレクション詳細"), 'コレクションのリンクからコレクション詳細画面へ遷移できません'
            expect(page).to have_content(item.title.name), 'コレクションリストにコレクションのタイトルが表示されていません'
            expect(page).to have_content(item.artist_name.name), 'コレクションリストにコレクションのアーティスト名が表示されていません'
            item.tags.each do |tag|
              expect(page).to have_content(tag.name), 'コレクションリストにコレクションのタグが表示されていません'
            end
          end
        end

        context '他人のアイテム' do
          let(:other_user_item) { create(:item, :collection, user: another_user) }
          it '閲覧できないこと' do
            visit item_path(other_user_item)
            expect(page).to have_content("指定されたアイテムが見つかりません"), 'エラーメッセージ「指定されたアイテムが見つかりません」が表示されていません'
          end
        end
      end
    end

    describe 'アイテムの作成' do
      context 'ログインしていない場合' do
        it 'ログインページにリダイレクトされること' do
          visit 'items/new'
          expect(page).to have_current_path("/login", ignore_query: true), 'ログインページへ遷移できません'
          expect(page).to have_content('ログインしてください'), 'フラッシュメッセージ「ログインしてください」が表示されていません'
        end
      end

      context 'ログインしている場合' do
        before do
          login(user)
        end
        context 'コレクション' do
          it 'コレクションが作成できること' do
            visit new_item_path(role: 'collection')
            fill_in 'タイトル', with: 'title'
            fill_in 'アーティスト名', with: 'artist'
            fill_in 'フォーマット', with: 'format'
            fill_in 'プレス国', with: 'presscountry'
            fill_in 'マトリクスナンバー', with: 'number'
            select 'New', from: 'item_condition_id'
            select '帯', from: 'item_accessory_ids'
            fill_in 'タグ', with: 't,a,g'
            fill_in 'メモ', with: 'memo'
            click_on '保存'
            expect(page).to have_content('アイテムを作成しました'), 'フラッシュメッセージ「アイテムを作成しました」が表示されていません'
            expect(page).to have_content('title'), '作成したアイテムのタイトルが表示されていません'
            expect(page).to have_content('artist'), '作成したアイテムのアーティスト名が表示されていません'
            expect(page).to have_content('format'), '作成したアイテムのフォーマットが表示されていません'
            expect(page).to have_content('presscountry'), '作成したアイテムのプレス国が表示されていません'
            expect(page).to have_content('New'), '作成したアイテムの状態が表示されていません'
            expect(page).to have_content('帯'), '作成したアイテムの付属品が表示されていません'
            expect(page).to have_content('t'), '作成したアイテムのタグが表示されていません'
            expect(page).to have_content('a'), '作成したアイテムのタグが表示されていません'
            expect(page).to have_content('g'), '作成したアイテムのタグが表示されていません'
            expect(page).to have_content('memo'), '作成したアイテムのメモが表示されていません'
          end

          it 'コレクションの作成に失敗すること', js: true do
            visit new_item_path(role: 'collection')
            fill_in 'タイトル', with: 'title'
            fill_in 'アーティスト名', with: ''
            click_on '保存'
            expect(page).to have_current_path(new_item_path, ignore_query: true), 'コレクションの作成に失敗していません'
          end
        end

        context '欲しいもの' do
          it '欲しいものが作成できること' do
            visit new_item_path(role: 'want')
            fill_in 'タイトル', with: 'title'
            fill_in 'アーティスト名', with: 'artist'
            fill_in 'フォーマット', with: 'format'
            fill_in 'プレス国', with: 'presscountry'
            fill_in 'マトリクスナンバー', with: 'number'
            select 'New', from: 'item_condition_id'
            select '帯', from: 'item_accessory_ids'
            fill_in 'タグ', with: 't,a,g'
            fill_in 'メモ', with: 'memo'
            click_on '保存'
            expect(page).to have_content('アイテムを作成しました'), 'フラッシュメッセージ「アイテムを作成しました」が表示されていません'
            expect(page).to have_content('title'), '作成したアイテムのタイトルが表示されていません'
            expect(page).to have_content('artist'), '作成したアイテムのアーティスト名が表示されていません'
            expect(page).to have_content('format'), '作成したアイテムのフォーマットが表示されていません'
            expect(page).to have_content('presscountry'), '作成したアイテムのプレス国が表示されていません'
            expect(page).to have_content('New'), '作成したアイテムの状態が表示されていません'
            expect(page).to have_content('帯'), '作成したアイテムの付属品が表示されていません'
            expect(page).to have_content('t'), '作成したアイテムのタグが表示されていません'
            expect(page).to have_content('a'), '作成したアイテムのタグが表示されていません'
            expect(page).to have_content('g'), '作成したアイテムのタグが表示されていません'
            expect(page).to have_content('memo'), '作成したアイテムのメモが表示されていません'
          end

          it '欲しいものの作成に失敗すること' do
            visit new_item_path(role: 'want')
            fill_in 'タイトル', with: 'title'
            fill_in 'アーティスト名', with: ''
            click_on '保存'
            expect(page).to have_current_path(new_item_path, ignore_query: true), '欲しいものの作成に失敗していません'
          end
        end
      end
    end

    describe 'アイテムの編集' do
      context 'ログインしていない場合' do
        let!(:item) { create(:item, :collection, user: user) }
        it 'ログインページにリダイレクトされること' do
          visit edit_item_path(item)
          expect(page).to have_current_path("/login", ignore_query: true), 'ログインページへ遷移できません'
          expect(page).to have_content('ログインしてください'), 'フラッシュメッセージ「ログインしてください」が表示されていません'
        end
      end

      context 'ログインしている場合' do
        before do
          login(user)
        end
        context '自分のアイテム' do
          context 'コレクション' do
            let!(:item) { create(:item, :collection, user: user) }
            it '編集できること' do
              visit edit_item_path(item)
              fill_in 'タイトル', with: '編集後のtitle'
              fill_in 'アーティスト名', with: '編集後のartist'
              click_button '更新'
              expect(page).to have_content('アイテムを更新しました'), 'フラッシュメッセージ「アイテムを更新しました」が表示されていません'
              expect(page).to have_content('編集後のtitle'), '更新後のタイトルが表示されていません'
              expect(page).to have_content('編集後のartist'), '更新後のアーティスト名が表示されていません'
            end

            it '編集に失敗すること' do
              visit edit_item_path(item)
              fill_in 'タイトル', with: '編集後のtitle'
              fill_in 'アーティスト名', with: ''
              click_button '更新'
              expect(page).to have_current_path(edit_item_path(item), ignore_query: true), 'コレクションの編集に失敗していません'
            end
          end

          context '欲しいもの' do
            let!(:item) { create(:item, :want, user: user) }
            it '編集できること' do
              visit edit_item_path(item)
              fill_in 'タイトル', with: '編集後のtitle'
              fill_in 'アーティスト名', with: '編集後のartist'
              click_button '更新'
              expect(page).to have_content('アイテムを更新しました'), 'フラッシュメッセージ「アイテムを更新しました」が表示されていません'
              expect(page).to have_content('編集後のtitle'), '更新後のタイトルが表示されていません'
              expect(page).to have_content('編集後のartist'), '更新後のアーティスト名が表示されていません'
            end

            it '編集に失敗すること' do
              visit edit_item_path(item)
              fill_in 'タイトル', with: '編集後のtitle'
              fill_in 'アーティスト名', with: ''
              click_button '更新'
              expect(page).to have_current_path(edit_item_path(item), ignore_query: true), '欲しいものの編集に失敗していません'
            end
          end
        end

        context '他人のアイテム' do
          let(:other_user_item) { create(:item, :collection, user: another_user) }
          it '編集フォームにアクセスできないこと' do
            visit edit_item_path(other_user_item)
            expect(page).to have_content("指定されたアイテムが見つかりません"), 'エラーメッセージ「指定されたアイテムが見つかりません」が表示されていません'
          end
        end
      end
    end

    describe '欲しいものの移動' do
      before do
        login(user)
      end
      it 'コレクションリストに移動できること', js: true do
        visit new_item_path(role: 'want')
        fill_in 'タイトル', with: '移動テストtitle'
        fill_in 'アーティスト名', with: '移動テストartist'
        click_button '保存'
        created_item = Item.find_by(title: Title.find_by(name: '移動テストtitle'), artist_name: ArtistName.find_by(name: '移動テストartist'))
        visit '/want_items'
        find("[data-tip='コレクションに移動']").click
        expect(page).to have_content('欲しいものをコレクションに移動しました'), 'フラッシュメッセージ「欲しいものをコレクションに移動しました」が表示されていません'
        visit '/collection_items'
        expect(page).to have_content('移動テストtitle'), '移動したアイテムが表示されていません'
      end
    end

    describe 'アイテムの削除' do
      before do
        login(user)
      end
      context 'コレクション' do
        let!(:item) { create(:item, :collection, user: user) }
        it 'アイテムの削除ができること', js: true do
          visit '/collection_items'
          expect {
            find("[data-tip='削除']").click
            page.accept_confirm
            expect(page).to have_content('コレクションを削除しました'), 'フラッシュメッセージ「コレクションを削除しました」が表示されていません'
          }.not_to change(Item, :count)
          expect(page).to have_current_path("/collection_items", ignore_query: true), 'コレクション一覧が表示されていません'
          expect(item.reload.status).to eq('deleted')
          expect(page).not_to have_content(item.title.name)
        end
      end

      context '欲しいもの' do
        let!(:item) { create(:item, :want, user: user) }
        it 'アイテムの削除ができること' do
          visit '/want_items'
          expect {
            find("[data-tip='削除']").click
            page.accept_confirm
            expect(page).to have_content('欲しいものを削除しました'), 'フラッシュメッセージ「欲しいものを削除しました」が表示されていません'
          }.not_to change(Item, :count)
          expect(page).to have_current_path("/want_items", ignore_query: true), '欲しいもの一覧が表示されていません'
          expect(item.reload.status).to eq('deleted')
          expect(page).not_to have_content(item.title.name)
        end
      end
    end

    describe 'アイテム検索' do
      it '' do
      end
    end
  end
end
