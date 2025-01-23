# typed: strict

class Homebrew::Cmd::BundleCmd
  sig { returns(Homebrew::Cmd::BundleCmd::Args) }
  def args; end
end

class Homebrew::Cmd::BundleCmd::Args < Homebrew::CLI::Args
  sig { returns(T::Boolean) }
  def all?; end

  sig { returns(T::Boolean) }
  def brews?; end

  sig { returns(T::Boolean) }
  def cask?; end

  sig { returns(T::Boolean) }
  def casks?; end

  sig { returns(T::Boolean) }
  def cleanup?; end

  sig { returns(T::Boolean) }
  def describe?; end

  sig { returns(T.nilable(String)) }
  def file; end

  sig { returns(T::Boolean) }
  def force?; end

  sig { returns(T::Boolean) }
  def formula?; end

  sig { returns(T::Boolean) }
  def global?; end

  sig { returns(T::Boolean) }
  def mas?; end

  sig { returns(T::Boolean) }
  def no_lock?; end

  sig { returns(T::Boolean) }
  def no_restart?; end

  sig { returns(T::Boolean) }
  def no_upgrade?; end

  sig { returns(T::Boolean) }
  def no_vscode?; end

  sig { returns(T::Boolean) }
  def tap?; end

  sig { returns(T::Boolean) }
  def taps?; end

  sig { returns(T::Boolean) }
  def upgrade?; end

  sig { returns(T::Boolean) }
  def verbose?; end

  sig { returns(T::Boolean) }
  def vscode?; end

  sig { returns(T::Boolean) }
  def whalebrew?; end

  sig { returns(T::Boolean) }
  def zap?; end
end
