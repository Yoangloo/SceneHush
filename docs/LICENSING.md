# License selection / 开源协议选择 / ライセンスの選定

[English](#english) · [简体中文](#简体中文) · [日本語](#日本語)

## English

**Recommendation: MIT.** SceneHush is a small desktop utility intended to be easy to use, inspect, modify, and redistribute. MIT keeps the license short and allows both open-source and commercial reuse while requiring preservation of its copyright and license notice.

The actual license text governs use. Read the [MIT](https://opensource.org/license/mit), [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0), and [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.html) texts for the full terms.

| License | Main distinction | Fit for SceneHush |
| --- | --- | --- |
| MIT | Permissive; retain copyright and license notice. | Recommended: simple terms and low redistribution friction. |
| BSD 3-Clause | Permissive, with an additional restriction on using contributor names for endorsement. | Reasonable alternative, but adds a condition this project does not currently need. |
| Apache 2.0 | Permissive, with explicit patent terms and additional notice requirements. | Useful when those terms are a project priority; more text and compliance detail for a small utility. |
| GPL 3.0 | Copyleft; distributing covered modified software carries corresponding source and license obligations. | Appropriate if keeping distributed derivatives under copyleft is the main goal; that is not this project's chosen policy. |

The selected [MIT License](../LICENSE) applies to SceneHush's own source code and included project materials unless a file states otherwise. **It does not relicense BetterDisplay.** Native mode does not require BetterDisplay. Users who choose the optional BetterDisplay mode install that separate product under its own terms; it is not included in the app or release archives. Apple frameworks and build tools also retain their respective terms.

If a future contribution adds third-party code or assets, document its origin and license before including it. A dependency's license must not be inferred from SceneHush's MIT license.

## 简体中文

**推荐采用 MIT。** SceneHush 是一个小型桌面工具，希望使用者能方便地阅读、修改、二次分发，也允许商业使用。MIT 条款简短，要求保留版权及许可声明，符合本项目的发布目标。

下表供项目选型参考，完整权利和义务以协议原文为准。

| 协议 | 主要区别 | 对 SceneHush 的适合程度 |
| --- | --- | --- |
| MIT | 宽松；需保留版权与许可声明。 | 推荐，条款简短，便于分发与复用。 |
| BSD 3-Clause | 宽松；另有限制使用贡献者姓名为衍生产品背书的条款。 | 可选，但本项目暂不需要增加这项条件。 |
| Apache 2.0 | 宽松；包含明确的专利条款及额外的声明要求。 | 重视这些条款时适用；对小工具而言，文本和遵循细节更多。 |
| GPL 3.0 | Copyleft；分发受其约束的修改版本时，涉及相应源码和许可义务。 | 适合以衍生版本继续开源为主要目标的项目；本项目选择宽松复用。 |

最终采用的 [MIT 协议](../LICENSE) 适用于 SceneHush 自身源码和项目材料，文件另有说明时除外。**MIT 不会改变 BetterDisplay 的许可。** 原生模式无需 BetterDisplay；只有选择可选的 BetterDisplay 模式时，才需按其自身条款另行安装。SceneHush 不打包或再分发 BetterDisplay；Apple 框架及构建工具也保留各自条款。

未来引入第三方代码或素材时，应先注明来源及其许可，不能因为本项目使用 MIT，就推定第三方内容也使用 MIT。

## 日本語

**MIT を推奨します。** SceneHush は、利用、確認、変更、再配布をしやすくしたい小さなデスクトップユーティリティです。MIT は短い条文で、著作権表示とライセンス表示を残すことを条件に、商用利用を含む再利用を認めます。

以下は選定のための要約です。実際の権利と義務にはライセンス本文が適用されます。

| ライセンス | 主な違い | SceneHush との適合 |
| --- | --- | --- |
| MIT | 寛容。著作権表示とライセンス表示の維持が必要。 | 推奨。短く、再利用・再配布しやすい条件です。 |
| BSD 3-Clause | 寛容。貢献者名を製品の推奨に利用することへの追加条件があります。 | 選択肢ですが、現時点で本プロジェクトに必要な追加条件ではありません。 |
| Apache 2.0 | 寛容。明示的な特許条項と追加の通知要件があります。 | それらの条件を重視する場合に適しますが、小さなツールには条文と対応事項が増えます。 |
| GPL 3.0 | コピーレフト。対象となる変更版の配布には、対応するソースやライセンス上の義務があります。 | 派生版の継続的なコピーレフトを目的とする場合に適します。本プロジェクトでは寛容な再利用を選びます。 |

採用した [MIT ライセンス](../LICENSE) は、別途記載のない SceneHush 自体のソースコードと同梱プロジェクト資料に適用されます。**BetterDisplay のライセンスは変更しません。** ネイティブモードでは BetterDisplay は不要です。任意の BetterDisplay モードを選ぶ利用者のみ、その規約に従って別途インストールします。アプリや配布アーカイブには含めません。Apple のフレームワークとビルドツールにも、それぞれの条件が適用されます。

第三者のコードや素材を将来追加する場合は、含める前に出典とライセンスを記載してください。SceneHush が MIT であることから、依存する素材も MIT だと推測してはいけません。
