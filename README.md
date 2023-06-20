# Tracker

Приложение помогает пользователям формировать полезные привычки и контролировать их выполнение.
Цели приложения:

* Контроль привычек по дням недели;
* Просмотр прогресса по привычкам;

# Table of Contents
1. [Description](#description)
2. [Getting started](#getting-started)
3. [Usage](#usage)
4. [Arhitecture](#arhitecture)
5. [Structure](#structure)
6. [Dependencies](#dependencies)
7. [Workflow](#workflow)
8. [Task board](#task-board)
9. [Design](#design)

# Description

* Приложение состоит из карточек-трекеров, которые создает пользователь. Он может указать название, категорию и задать расписание. Также можно выбрать эмодзи и цвет, чтобы отличать карточки друг от друга.
* Карточки отсортированы по категориям. Пользователь может искать их с помощью поиска и фильтровать.
* С помощью календаря пользователь может посмотреть какие привычки у него запланированы на конкретный день.
* В приложении есть статистика, которая отражает успешные показатели пользователя, его прогресс и средние значения.

Полное описание функциональных требований находится в [техническом задании](https://github.com/Yandex-Practicum/iOS-TrackerApp-Public)

# Getting started

1. Убедитесь что на компьютере установлен Xcode версии 13 или выше.
2. Загрузите файлы Tracker проекта из репозитория.
3. Откройте файл проекта в Xcode.
5. Запустите активную схему.

# Usage

[In progress]

# Architecture

[In progress]

* Clean Swift
* Navigation: Coordinator
* DI: на базе фабрик
* Persistence storage: Core Data
* Layout: Anchors, CompositionalLayout
* Fonts: YSDisplay

# Structure

* "App": App и Scene delegates, глобальные объекты приложения: DI, навигация и др.
* "Models": Модели объектов
* "Modules": Содержит модули приложения (UI + код)
* "Library": Протоколы, расширения и утилиты
* "Resources": Ресурсы приложения: картинки, шрифты и другие типы ресурсов. А также файлы: 
    - Theme.swift - содержит статические методы по поддержке работы с ресурсами приложения и некоторые дополнительные сервисные методы.
    - LaunchScreen.storyboard
    - Info.plist

# Dependencies

[In progress]


# Workflow

* Задачи по спринту выполняются в отдельной ветке sprint-X, где X - номер спринта
* По окончанию работ создается PR на вливание в ветку main и отдается на проверку
* После успешной проверки и получении апрува изменения вливаются в main через merge request (с опцией squash) и ветка для разработки удаляется

## Branches

* main - стабильные версии приложения
* sprint-X - ветки для разработки

## Requirements for commit

* Названия коммитов должны быть согласно [гайдлайну](https://www.conventionalcommits.org/ru/v1.0.0/)
* Тип коммита должен быть только в нижнием регистре (feat, fix, refactor, docs и т.д.)
* Должен использоваться present tense ("add feature" not "added feature")
* Должен использоваться imperative mood ("move cursor to..." not "moves cursor to...")

### Examples

* `feat:` - это реализованная новая функциональность из технического задания (добавил поддержку зумирования, добавил footer, добавил карточку продукта). Примеры:

```
feat: add basic page layout
feat: implement search box
feat: implement request to youtube API
feat: implement swipe for horizontal list
feat: add additional navigation button
```

* `fix:` - исправил ошибку в ранее реализованной функциональности. Примеры:

```
fix: implement correct loading data from youtube
fix: change layout for video items to fix bugs
fix: relayout header for firefox
fix: adjust social links for mobile
```

* `refactor:` - новой функциональности не добавлял / поведения не менял. Файлы в другие места положил, удалил, добавил. Изменил форматирование кода (white-space, formatting, missing semi-colons, etc). Улучшил алгоритм, без изменения функциональности. Примеры:

```
refactor: change structure of the project
refactor: rename vars for better readability
refactor: apply prettier
```

* `docs:` - используется при работе с документацией/readme проекта. Примеры:

```
docs: update readme with additional information
docs: update description of run() method
```

[Источник](https://docs.rs.school/#/git-convention?id=%d0%9f%d1%80%d0%b8%d0%bc%d0%b5%d1%80%d1%8b-%d0%b8%d0%bc%d0%b5%d0%bd-%d0%ba%d0%be%d0%bc%d0%bc%d0%b8%d1%82%d0%be%d0%b2)

## Tools

В проекте используются:

- [SwiftLint](https://github.com/realm/SwiftLint) - для обеспечения соблюдения стиля и соглашений Swift

```sh
brew update
brew install swiftlint
```

- Live Preview с помощью SwifUI

```swift
#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ViewProvider: PreviewProvider {
	static var previews: some View {
		let viewController = ViewController()
		let labelView = viewController.makeWelcomeLabel() as UIView
		let labelView2 = viewController.makeWelcomeLabel() as UIView
		Group {
			viewController.preview()
			VStack(spacing: 0) {
				labelView.preview().frame(height: 100).padding(.bottom, 20)
				labelView2.preview().frame(height: 100).padding(.bottom, 20)
			}
		}
	}
}
#endif
```

# Task board

* Доска задач не используется
* Задачи описываются в issue и связываются с ветками для разработки

# Design

* Инструментом для дизайна является [Figma](https://www.figma.com)
* [Дизайн приложения](https://www.figma.com/file/owAO4CAPTJdpM1BZU5JHv7/Tracker-(YP)?node-id=1-60&t=wx7839tYLbl9jGW8-0) 
