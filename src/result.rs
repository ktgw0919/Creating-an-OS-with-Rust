// エラー時の型を固定文字列に限定
pub type Result<T> = core::result::Result<T, &'static str>;
