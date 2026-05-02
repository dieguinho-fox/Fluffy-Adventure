using Godot;

public partial class Bootstrap : Node
{
	public override void _Ready()
	{
		var gameApi = new GameAPI();
		gameApi.Name = "GameAPI";

		GetTree().Root.AddChild(gameApi);

		Engine.RegisterSingleton("GameAPI", gameApi);

		GD.Print("[Bootstrap] GameAPI criado e inserido na árvore");
	}
}
