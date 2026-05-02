using Godot;

public partial class GameAPI : Node
{
	private Label _topLabel;

	public override void _Ready()
	{
		GD.Print("[GameAPI] Pronta");

		// cria o label
		_topLabel = new Label
		{
			Text = "",
			Visible = false
		};

		CallDeferred("add_child", _topLabel);
	}

	public void Log(string message)
	{
		GD.Print("[LuaMod] " + message);
	}

	public void ShowTopLabel(string text)
	{
		GD.Print("[GameAPI] ShowTopLabel chamado: " + text);

		if (_topLabel == null)
			return;

		_topLabel.Text = text;
		_topLabel.Visible = true;
	}
}
